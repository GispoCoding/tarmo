variable "AWS_REGION_NAME" {
  description = "AWS Region name."
  type        = string
}

variable "AWS_BUCKET_NAME" {
  description = "AWS S3 bucket name."
  type        = string
}

variable "AWS_S3_USER" {
  description = "AWS S3 user name."
  type        = string
}

variable "AWS_HOSTED_DOMAIN" {
  description = "Domain for create route53 record."
  type        = string
}

variable "enable_route53_record" {
  type    = bool
  default = false
}

variable "frontend_subdomain" {
  description = "Name of the site, used for example in  <SITE_NAME>.domain.com"
  default     = "tarmo"
  type        = string
}


locals {
  frontend_dns_alias = "${var.frontend_subdomain}.${var.AWS_HOSTED_DOMAIN}"
}

locals {
  s3_origin_id = "tarmo-react-app"
}
