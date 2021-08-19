resource "aws_route53_record" "abbyy_rds" {
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = "${var.name}db"
  type    = "CNAME"
  ttl     = "300"
  records = [module.abbyy_rds.this_db_instance_address]
}
