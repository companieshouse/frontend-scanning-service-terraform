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
    "abbyy" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Scanning App"
        source_security_group_id = data.aws_security_group.fes_app_asg.id
      }
    ]
    "fes"   = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend EWF"
        source_security_group_id = data.aws_security_group.ewf_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Scanning App"
        source_security_group_id = data.aws_security_group.fes_app_asg.id
    }
    ]
  }

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
