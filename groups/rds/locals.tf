# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs    = values(data.vault_generic_secret.internal_cidrs.data)

  app_cidrs = {
    "abbyy" = []
    "fes" = values(data.vault_generic_secret.chs_cidrs.data)
  }

  rds_data = {
    abbyy = data.vault_generic_secret.abbyy_rds.data
    fes   = data.vault_generic_secret.fes_rds.data
  }

  rds_ingress_from_services = {
    "abbyy" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_abbyy : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
   "fes" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_fes : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
  }

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  fes_dba_dev_ingress_cidrs_list = jsondecode(data.vault_generic_secret.fes_rds.data_json)["dba-dev-cidrs"]

  dba_dev_ingress_instances_map = {
    fes = local.fes_dba_dev_ingress_cidrs_list,
  }

  dba_dev_ingress_rules_map = merge([
    for instance, cidrs in local.dba_dev_ingress_instances_map : {
      for idx, cidr in cidrs : "${instance}_${idx}" => {
        cidr  = cidr
        sg_id = module.rds_security_group[instance].this_security_group_id
      }
    }
  ]...)

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
