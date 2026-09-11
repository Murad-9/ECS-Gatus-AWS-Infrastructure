# ACM 

resource "aws_acm_certificate" "gatus" {
  domain_name       = "tm.gatuslabs.online"
  validation_method = "DNS"

}


# ACM certif validation

resource "aws_acm_certificate_validation" "gatus" {
  certificate_arn         = aws_acm_certificate.gatus.arn
  validation_record_fqdns = var.validation_record_fqdns
}