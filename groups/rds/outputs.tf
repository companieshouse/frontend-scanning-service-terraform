output "abbyy_rds_address" {
  value = aws_route53_record.abbyy_rds.fqdn
}

output "fes_rds_address" {
  value = aws_route53_record.fes_rds.fqdn
}
