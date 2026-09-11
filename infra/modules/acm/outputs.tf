output "domain_validation_options" {
  value = aws_acm_certificate.gatus.domain_validation_options
}

output "certificate_arn" {
  value = aws_acm_certificate.gatus.arn
}