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
  description = "Version number of the PostgreSQL DB. DEfault: 13.4"
  type        = string
  default     = "13.3"
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


locals {
  frontend_dns_alias = "${var.frontend_subdomain}.${var.AWS_HOSTED_DOMAIN}"
}

locals {
  s3_origin_id = "tarmo-react-app"
}
