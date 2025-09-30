module "fes_app_profile" {
  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=tags/1.0.59"

  name       = "fes-frontend-profile"
  enable_SSM = true
  cw_log_group_arns = length(local.fes_app_log_groups) > 0 ? flatten([
    formatlist(
      "arn:aws:logs:%s:%s:log-group:%s:*:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.fes_app_log_groups
    ),
    formatlist("arn:aws:logs:%s:%s:log-group:%s:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.fes_app_log_groups
    ),
  ]) : null
  instance_asg_arns = [module.fes_app_asg.this_autoscaling_group_arn]
  kms_key_refs = [
    "alias/${var.account}/${var.region}/ebs",
    local.ssm_kms_key_id
  ]
  s3_buckets_write = [local.session_manager_bucket_name]

  custom_statements = [
    {
      sid    = "AllowAccessToReleaseBucket",
      effect = "Allow",
      resources = [
        "arn:aws:s3:::${local.s3_releases["release_bucket_name"]}/*",
        "arn:aws:s3:::${local.s3_releases["release_bucket_name"]}",
        "arn:aws:s3:::${local.s3_releases["config_bucket_name"]}/*",
        "arn:aws:s3:::${local.s3_releases["config_bucket_name"]}",
        "arn:aws:s3:::${local.s3_releases["resources_bucket_name"]}/*",
        "arn:aws:s3:::${local.s3_releases["resources_bucket_name"]}"
      ],
      actions = [
        "s3:Get*",
        "s3:List*",
      ]
    }
  ]

}
