output "rds_address" {
  value = aws_route53_record.abbyy_rds.fqdn
}
