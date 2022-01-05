# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs     = values(data.vault_generic_secret.internal_cidrs.data)
  abbyy_rds_data  = data.vault_generic_secret.abbyy_rds.data
  fes_rds_data    = data.vault_generic_secret.fes_rds.data

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
