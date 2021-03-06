# ------------------------------------------------------------------------------
# FES Security Group and rules
# ------------------------------------------------------------------------------
module "fes_app_ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.application}-app-001"
  description = "Security group for the ${var.application} app ec2"
  vpc_id      = data.aws_vpc.vpc.id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.fes_app_internal_alb_security_group.this_security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}

resource "aws_cloudwatch_log_group" "fes_app" {
  for_each = local.fes_app_cw_logs

  name              = each.value["log_group_name"]
  retention_in_days = lookup(each.value, "log_group_retention", var.fes_app_default_log_group_retention_in_days)
  kms_key_id        = lookup(each.value, "kms_key_id", local.logs_kms_key_id)

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-Support"
    )
  )
}

# ASG Scheduled Shutdown
resource "aws_autoscaling_schedule" "fes-schedule-stop" {

  scheduled_action_name  = "${var.aws_account}-${var.application}-app-scheduled-shutdown"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.fes_app_scaling_schedule_stop
  autoscaling_group_name = module.fes_app_asg.this_autoscaling_group_name
}

# ASG Scheduled Startup
resource "aws_autoscaling_schedule" "fes-schedule-start" {

  scheduled_action_name  = "${var.aws_account}-${var.application}-app-scheduled-startup"
  min_size               = var.fes_app_min_size
  max_size               = var.fes_app_max_size
  desired_capacity       = var.fes_app_desired_capacity
  recurrence             = var.fes_app_scaling_schedule_start
  autoscaling_group_name = module.fes_app_asg.this_autoscaling_group_name
}

# ASG Module
module "fes_app_asg" {
  source = "git@github.com:companieshouse/terraform-modules//aws/terraform-aws-autoscaling?ref=tags/1.0.36"

  name = "${var.application}-app"
  # Launch configuration
  lc_name       = "${var.application}-app-launchconfig"
  image_id      = data.aws_ami.fes_app.id
  instance_type = var.fes_app_instance_size
  security_groups = [
    module.fes_app_ec2_security_group.this_security_group_id,
    data.aws_security_group.nagios_shared.id
  ]
  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
      encrypted   = true
      iops        = 0
    },
  ]
  # Auto scaling group
  asg_name                       = "${var.application}-app-asg"
  vpc_zone_identifier            = data.aws_subnet_ids.application.ids
  health_check_type              = "ELB"
  min_size                       = var.fes_app_min_size
  max_size                       = var.fes_app_max_size
  desired_capacity               = var.fes_app_desired_capacity
  health_check_grace_period      = 300
  wait_for_capacity_timeout      = 0
  force_delete                   = true
  enable_instance_refresh        = true
  refresh_min_healthy_percentage = 50
  refresh_triggers               = ["launch_configuration"]
  key_name                       = aws_key_pair.fes_app_keypair.key_name
  termination_policies           = ["OldestLaunchConfiguration"]
  target_group_arns              = module.fes_app_internal_alb.target_group_arns
  iam_instance_profile           = module.fes_app_profile.aws_iam_instance_profile.name
  user_data_base64               = data.template_cloudinit_config.fes_app_userdata_config.rendered

  tags_as_map = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-Support"
    )
  )

  depends_on = [
    module.fes_app_internal_alb
  ]
}


#--------------------------------------------
# Internal ALB CloudWatch Alarms
#--------------------------------------------
module "asg_alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/asg-cloudwatch-alarms?ref=tags/1.0.103"

  autoscaling_group_name = module.fes_app_asg.this_autoscaling_group_name
  prefix                 = "${var.application}-fe-asg-alarms"

  in_service_evaluation_periods      = "3"
  in_service_statistic_period        = "120"
  expected_instances_in_service      = var.fes_app_desired_capacity
  in_pending_evaluation_periods      = "3"
  in_pending_statistic_period        = "120"
  in_standby_evaluation_periods      = "3"
  in_standby_statistic_period        = "120"
  in_terminating_evaluation_periods  = "3"
  in_terminating_statistic_period    = "120"
  total_instances_evaluation_periods = "3"
  total_instances_statistic_period   = "120"
  total_instances_in_service         = var.fes_app_desired_capacity

  # If actions are used then all alarms will have these applied, do not add any actions which you only want to be used for specific alarms
  # The module has lifecycle hooks to ignore changes via the AWS Console so in this use case the alarm can be modified there.
  actions_alarm = var.enable_sns_topic ? [module.cloudwatch_sns_notifications[0].sns_topic_arn] : []
  actions_ok    = var.enable_sns_topic ? [module.cloudwatch_sns_notifications[0].sns_topic_arn] : []


  depends_on = [
    module.cloudwatch_sns_notifications,
    module.fes_app_asg
  ]
}