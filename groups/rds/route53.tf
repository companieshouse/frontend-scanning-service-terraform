resource "aws_route53_record" "abbyy_rds" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = "${var.abbyy_name}db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.abbyy_rds.this_db_instance_address]
}

resource "aws_route53_record" "fes_rds" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = "${var.fes_name}db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.fes_rds.this_db_instance_address]
}
