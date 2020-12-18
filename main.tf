terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
  }
    required_version = ">= 0.14"

    backend "s3" {
        bucket  = "terraform-remote-state-bucket-s3"
        key     = "worstpaladin-eu/terraform.tfstate"
        region  = "eu-west-2"
        encrypt = true
    }
}

provider "aws" {
    region = var.aws_region
}

module "dns" {
    source = "./modules/dns"

    domain         = var.domain
    delegation_set = var.delegation_set
    hosted_zone_id = module.s3.hosted_zone_id
    website_domain = module.s3.website_domain
}

module "s3" {
    source = "./modules/s3"

    domain = var.domain
    
}
