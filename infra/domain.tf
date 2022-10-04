data "aws_route53_zone" "zone" {
  count = 1
  name  = var.AWS_HOSTED_DOMAIN
}

data "aws_route53_zone" "alternate-zone" {
  # also register alternate domains if present
  for_each = toset(var.alternate_domains)
  name  = each.value
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

resource "aws_route53_record" "frontend-alternate" {
  # also register alternate domains if present
  for_each = data.aws_route53_zone.alternate-zone

  zone_id = each.value.id
  name    = each.value.name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_validation" {
# this should validate all the domains in the certificate
  for_each = length(aws_acm_certificate.frontend) > 0 ? {
    for index, dvo in aws_acm_certificate.frontend[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
      # fingers crossed the ordering of alternate zones is the same in the certificate and in the zone set
      # is there a better way to do this? zones and domains have the same names but that won't help us here
      zone_id = dvo.domain_name == local.frontend_dns_alias ? data.aws_route53_zone.zone[0].id : data.aws_route53_zone.alternate-zone[dvo.domain_name].id
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_route53_record" "tileserver" {
  # Always create the tile server route, no matter what the frontend domain
  count = 1

  zone_id = data.aws_route53_zone.zone[0].id
  name    = local.tileserver_dns_alias
  type    = "CNAME"

  records = [
    aws_lb.tileserver.dns_name
  ]
  ttl     = "60"
}

resource "aws_route53_record" "tileserver_validation" {

  for_each = {
  for dvo in aws_acm_certificate.tileserver[0].domain_validation_options : dvo.domain_name => {
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
