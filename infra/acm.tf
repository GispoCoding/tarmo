# ACM needs to be created in us-east-1 in order to use it with Cloudfront

provider "aws" {
  alias  = "us1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "frontend" {
  count             = var.enable_route53_record ? 1 : 0
  domain_name       = local.frontend_dns_alias
  validation_method = "DNS"

  provider = aws.us1
}

resource "aws_acm_certificate" "tileserver" {
  count             = var.enable_route53_record ? 1 : 0
  domain_name       = local.tileserver_dns_alias
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "frontend" {
  count                   = var.enable_route53_record ? 1 : 0
  certificate_arn         = aws_acm_certificate.frontend[0].arn
  validation_record_fqdns = [for record in aws_route53_record.frontend_validation : record.fqdn]

  provider = aws.us1
}

resource "aws_acm_certificate_validation" "tileserver" {
  count                   = var.enable_route53_record ? 1 : 0
  certificate_arn         = aws_acm_certificate.tileserver[0].arn
  validation_record_fqdns = [for record in aws_route53_record.tileserver_validation : record.fqdn]
}
