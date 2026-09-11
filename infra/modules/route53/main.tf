# route 53 zone

data "aws_route53_zone" "primary" {
  name = "gatuslabs.online"

}

# route 53 record

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.primary.zone_id


  for_each = {
  for dvo in var.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
}

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type

}

# route 53 record

resource "aws_route53_record" "gatus" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "tm.gatuslabs.online"
  type    = "A"

  alias {
  name                   = var.alb_dns_name
  zone_id                = var.alb_zone_id
  evaluate_target_health = true
}
}