output "frontend_route53_dns_record" {
  description = "The Route53 DNS name attached to CloudFront."
  value       = element(concat(aws_route53_record.frontend.*.name, [""]), 0)
}

output "cloudfront_dns_record" {
  description = "The CloudFront DNS name"
  value       = aws_cloudfront_distribution.cf_distribution.domain_name
}
