# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs    = values(data.vault_generic_secret.internal_cidrs.data)

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

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
