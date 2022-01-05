# ------------------------------------------------------------------------------
# RDS Security Group and rules
# ------------------------------------------------------------------------------
module "abbyy_rds_security_group" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.abbyy_name}-rds-001"
  description = "Security group for the ${var.abbyy_name} RDS database"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = concat(local.admin_cidrs, var.abbyy_rds_onpremise_access)
  ingress_rules       = ["oracle-db-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5500
      to_port     = 5500
      protocol    = "tcp"
      description = "Oracle Enterprise Manager"
      cidr_blocks = join(",", concat(local.admin_cidrs, var.abbyy_rds_onpremise_access))
    }
  ]
  ingress_with_source_security_group_id = []

  egress_rules = ["all-all"]
}

# ------------------------------------------------------------------------------
# RDS Instance
# ------------------------------------------------------------------------------
module "abbyy_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.23.0" # Pinned version to ensure updates are a choice, can be upgraded if new features are available and required.

  create_db_parameter_group = "true"
  create_db_subnet_group    = "true"

  identifier                 = join("-", ["rds", var.abbyy_identifier, var.environment, "001"])
  engine                     = "oracle-se2"
  major_engine_version       = var.abbyy_major_engine_version
  engine_version             = var.abbyy_engine_version
  auto_minor_version_upgrade = var.abbyy_auto_minor_version_upgrade
  license_model              = var.abbyy_license_model
  instance_class             = var.abbyy_instance_class
  allocated_storage          = var.abbyy_allocated_storage
  storage_type               = var.abbyy_storage_type
  iops                       = var.abbyy_iops
  multi_az                   = var.multi_az
  storage_encrypted          = true
  kms_key_id                 = data.aws_kms_key.rds.arn

  name     = upper(var.abbyy_name)
  username = local.abbyy_rds_data["admin-username"]
  password = local.abbyy_rds_data["admin-password"]
  port     = "1521"

  deletion_protection       = true
  maintenance_window        = var.rds_maintenance_window
  backup_window             = var.rds_backup_window
  backup_retention_period   = var.abbyy_backup_retention_period
  skip_final_snapshot       = "false"
  final_snapshot_identifier = "${var.abbyy_identifier}-final-deletion-snapshot"

  # Enhanced Monitoring
  monitoring_interval             = "30"
  monitoring_role_arn             = data.aws_iam_role.rds_enhanced_monitoring.arn
  enabled_cloudwatch_logs_exports = var.rds_log_exports

  performance_insights_enabled          = var.environment == "live" ? true : false
  performance_insights_kms_key_id       = data.aws_kms_key.rds.arn
  performance_insights_retention_period = 7

  # RDS Security Group
  vpc_security_group_ids = [
    module.abbyy_rds_security_group.this_security_group_id,
    data.aws_security_group.rds_shared.id
  ]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.data.ids

  # DB Parameter group
  family = join("-", ["oracle-se2", var.abbyy_major_engine_version])

  parameters = var.parameter_group_settings

  options = [
    {
      option_name                    = "OEM"
      port                           = "5500"
      vpc_security_group_memberships = [module.abbyy_rds_security_group.this_security_group_id]
    },
    {
      option_name = "JVM"
    },
    {
      option_name = "SQLT"
      version     = "2018-07-25.v1"
      option_settings = [
        {
          name  = "LICENSE_PACK"
          value = "N"
        },
      ]
    },
    {
      option_name = "Timezone"
      option_settings = [
        {
          name  = "TIME_ZONE"
          value = "Europe/London"
        },
      ]
    }
  ]

  timeouts = {
    "create" : "80m",
    "delete" : "80m",
    "update" : "80m"
  }

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.abbyy_identifier)}-DBA-Support"
    )
  )
}
