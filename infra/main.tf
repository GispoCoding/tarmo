terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.69"
    }
  }
  required_version = ">= 0.14.9"
}


provider "aws" {
  region = var.AWS_REGION_NAME
}


output "frontend_route53_dns_record" {
  description = "The Route53 DNS name attached to CloudFront."
  value       = element(concat(aws_route53_record.frontend.*.name, [""]), 0)
}

output "cloudfront_dns_record" {
  description = "The CloudFront DNS name"
  value       = aws_cloudfront_distribution.cf_distribution.domain_name
}



