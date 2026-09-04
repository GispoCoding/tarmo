terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.63"
    }
  }
  required_version = ">= 0.14.9"
}


provider "aws" {
  region = var.AWS_REGION_NAME
}
