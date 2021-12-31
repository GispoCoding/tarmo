data "aws_route53_zone" "zone" {
  count = var.enable_route53_record ? 1 : 0
  name  = var.AWS_HOSTED_DOMAIN
}


resource "aws_route53_record" "frontend" {
  count = var.enable_route53_record ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].id
  name    = local.frontend_dns_alias
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_validation" {

  for_each = {
  for dvo in aws_acm_certificate.frontend[0].domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone[0].id
}
