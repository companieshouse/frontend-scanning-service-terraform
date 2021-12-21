# ------------------------------------------------------------------------------
# FES Security Group and rules
# ------------------------------------------------------------------------------
module "fes_ec2_security_group_defaults" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.application}-default"
  description = "Security group for the ${var.application} ec2"
  vpc_id      = data.aws_vpc.vpc.id

  #ingress_cidr_blocks = local.fes_access_ips
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  egress_rules = ["all-all"]
/*
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Web Subnet 80"
      cidr_blocks = join(",", var.vpc_sg_cidr_blocks_tcp)
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Web Subnet 443"
      cidr_blocks = join(",", var.vpc_sg_cidr_blocks_tcp)
    },
  ]
  */
}