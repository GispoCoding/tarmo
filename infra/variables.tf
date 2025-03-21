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

variable "AWS_LAMBDA_USER" {
  description = "AWS user for updating lambda functions"
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

variable "backend_subdomain" {
  description = "Name of the backend tileserver, used for example in  <SITE_NAME>.domain.com"
  default     = "tarmo-tilerserver"
  type        = string
}

variable "backend_cache_subdomain" {
  description = "Name of the backend tile cache, used for example in  <SITE_NAME>.domain.com"
  default     = "tarmo-tile-cache"
  type        = string
}

variable "mml_cache_subdomain" {
  description = "Name of the mml tile cache, used for example in  <SITE_NAME>.domain.com"
  default     = "tarmo-mml-cache"
  type        = string
}

variable "alternate_domains" {
  description = "Domains outside Route53 to map the frontend to. Only applied if enable_route_53_record is false."
  type        = list
  default     = []
}

variable "alternate_domain_certificate_arn" {
  description = "Existing certificate in AWS to use for the alternate domains. Only applied if enable_route_53_record is false."
  type        = string
}

variable "SLACK_HOOK_URL" {
  description = "Slack URL to post cloudwatch notifications to"
  type        = string
}

variable "bastion_public_key" {
  description = "Public ssh key to access the bastion EC2 instance"
  type        = string
}

variable "db_storage" {
  description = "DB Storage in GB"
  type        = number
  default     = 5
}

variable "db_instance_type" {
  description = "AWS instance type of the DB. Default: db.t3.micro"
  type        = string
  default     = "db.t3.micro"
}

variable "db_postgres_version" {
  description = "Version number of the PostgreSQL DB. DEfault: 13.7"
  type        = string
  default     = "13.15"
}

variable "tarmo_db_name" {
  description = "Tarmo DB Name"
  type        = string
  default     = "db"
}

variable "su_secrets" {
  default = {
    "username" = "postgres",
    "password" = "postgres"
  }
}

variable "tarmo_admin_secrets" {
  default = {
    "username" = "tarmo_admin",
    "password" = "postgres"
  }
}

variable "tarmo_r_secrets" {
  default = {
    "username" = "tarmo_read",
    "password" = "postgres"
  }
}

variable "tarmo_rw_secrets" {
  default = {
    "username" = "tarmo_read_write",
    "password" = "postgres"
  }
}


variable "pg_tileserv_port" {
  description = "Backend traffic port"
  type        = number
  default     = 7800
}

variable "varnish_port" {
  description = "Backend cache port"
  type        = number
  default     = 80
}

variable "public-subnet-count" {
  description = "TODO"
  type        = number
  default     = 2
}

variable "private-subnet-count" {
  description = "TODO"
  type        = number
  default     = 2
}

variable "pg_tileserv_cpu" {
  description = "CPU of the pg_tileserv"
  type        = number
  default     = 512
}

variable "pg_tileserv_memory" {
  description = "Memory of the pg_tileserv"
  type        = number
  default     = 1024
}

variable "pg_tileserv_image" {
  description = "Image of the pg_tileserv"
  default     = "docker.io/pramsey/pg_tileserv:20231005"
}

variable "varnish_cpu" {
  description = "CPU of the varnish cache"
  type        = number
  default     = 512
}

variable "varnish_memory" {
  description = "Memory of the varnish cache"
  type        = number
  default     = 4096
}

variable "varnish_image" {
  description = "Image of the varnish cache"
  default     = "docker.io/library/varnish:stable"
}

variable "prefix" {
  description = "Prefix to be used in resource names"
  type        = string
}

variable "extra_tags" {
  description = "Some extra tags for all resources. Use JSON format"
  type        = any
  default     = {}
}

locals {
  frontend_dns_alias   = "${var.frontend_subdomain}.${var.AWS_HOSTED_DOMAIN}"
  tileserver_dns_alias = "${var.backend_subdomain}.${var.AWS_HOSTED_DOMAIN}"
  tile_cache_dns_alias = "${var.backend_cache_subdomain}.${var.AWS_HOSTED_DOMAIN}"
  mml_cache_dns_alias = "${var.mml_cache_subdomain}.${var.AWS_HOSTED_DOMAIN}"
  default_tags         = merge(var.extra_tags, {
    "Prefix"    = var.prefix
    "Name"      = var.prefix
    "Terraform" = "true"
  })
}

locals {
  s3_origin_id = "${var.prefix}-react-app"
}
