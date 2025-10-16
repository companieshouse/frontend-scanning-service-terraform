data "aws_vpc" "vpc" {
  tags = {
    Name = "vpc-${var.aws_account}"
  }
}

data "aws_subnet_ids" "data" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["sub-data-*"]
  }
}

data "aws_security_group" "rds_shared" {
  filter {
    name   = "group-name"
    values = ["sgr-rds-shared-001*"]
  }
}

data "aws_security_group" "rds_ingress_abbyy" {
  count = length(var.rds_ingress_groups["abbyy"])
  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups["abbyy"][count.index]]
  }
}

data "aws_security_group" "rds_ingress_fes" {
  count = length(var.rds_ingress_groups["fes"])
  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups["fes"][count.index]]
  }
}

data "aws_route53_zone" "private_zone" {
  name         = local.internal_fqdn
  private_zone = true
}

data "aws_iam_role" "rds_enhanced_monitoring" {
  name = "irol-rds-enhanced-monitoring"
}

data "aws_kms_key" "rds" {
  key_id = "alias/kms-rds"
}

data "vault_generic_secret" "abbyy_rds" {
  path = "applications/${var.aws_profile}/abbyy/rds"
}

data "vault_generic_secret" "fes_rds" {
  path = "applications/${var.aws_profile}/fes/rds"
}

data "vault_generic_secret" "chs_cidrs" {
  path = "aws-accounts/network/${var.aws_account}/chs/application-subnets"
}

data "vault_generic_secret" "chs_cidrs_staging" {
  path = "aws-accounts/network/heritage-staging/chs/application-subnets"
}

data "aws_ec2_managed_prefix_list" "admin" {
  name = "administration-cidr-ranges"
}
