terraform {
  backend "s3" {
    bucket = "terraform-gispo"
    key = "tarmo.tfstate"
    region = "eu-central-1"
    encrypt = true
    kms_key_id = "arn:aws:kms:eu-central-1:631260641272:alias/terraform-bucket-key"
    dynamodb_table = "terraform-state"
    workspace_key_prefix = "tarmo"
  }
}
