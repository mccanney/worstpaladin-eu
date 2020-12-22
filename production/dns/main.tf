terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.22.0"
    }
  }
  required_version = ">= 0.14"

  backend "s3" {
    bucket  = "terraform-remote-state-bucket-s3"
    key     = "worstpaladin-eu/prod/dns/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

// We need to lookup values from the web bucket
// The S3 module must be created first though
data "terraform_remote_state" "web-bucket" {
  backend = "s3"
  config = {
    bucket = "terraform-remote-state-bucket-s3"
    key    = "worstpaladin-eu/prod/s3/terraform.tfstate"
    region = "eu-west-2"
  }
}

module "dns" {
  source = "../../modules/dns"

  domain         = var.domain
  delegation_set = var.delegation_set
  hosted_zone_id = data.terraform_remote_state.web-bucket.outputs.hosted_zone_id
  website_domain = data.terraform_remote_state.web-bucket.outputs.website_domain
}
