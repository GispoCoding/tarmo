# ACM needs to be created in us-east-1 in order to use it with Cloudfront

provider "aws" {
  alias  = "us1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "frontend" {
  count             = var.enable_route53_record ? 1 : 0
  domain_name       = local.frontend_dns_alias
  subject_alternative_names = var.alternate_domains
  validation_method = "DNS"
  tags              = merge(local.default_tags, { Name = "${var.prefix}-frontend-acm" })

  provider = aws.us1
}

resource "aws_acm_certificate" "tileserver" {
  # Always create the tile server certificate, no matter what the frontend domain
  count             = 1
  domain_name       = local.tileserver_dns_alias
  subject_alternative_names = [local.tile_cache_dns_alias, local.mml_cache_dns_alias]
  validation_method = "DNS"
  tags              = merge(local.default_tags, { Name = "${var.prefix}-tileserver-acm" })
}

resource "aws_acm_certificate_validation" "frontend" {
  count                   = var.enable_route53_record ? 1 : 0
  certificate_arn         = aws_acm_certificate.frontend[0].arn
  validation_record_fqdns = [for record in aws_route53_record.frontend_validation : record.fqdn]

  provider = aws.us1
}

resource "aws_acm_certificate_validation" "tileserver" {
  # Always create the tile server certificate, no matter what the frontend domain
  count                   = 1
  certificate_arn         = aws_acm_certificate.tileserver[0].arn
  validation_record_fqdns = [for record in aws_route53_record.tileserver_validation : record.fqdn]
}
