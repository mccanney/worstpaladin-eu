terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.22.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0.0"
    }
  }
  required_version = ">= 0.14"

  backend "s3" {
    bucket  = "terraform-remote-state-bucket-s3"
    key     = "worstpaladin-eu/prod/s3/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  html_files = [
    "index.html",
    "error.html"
  ]
}

resource "random_string" "name" {
  length  = 6
  upper   = false
  special = false
}

module "s3-web-bucket" {
  source = "../../modules/s3-web-bucket"

  bucket_name = var.domain
  environment = "Production"
}

module "s3-bucket" {
  source = "../../modules/s3-bucket"

  bucket_name = "${var.domain}-${random_string.name.result}"
  environment = "Production"
}

resource "aws_s3_bucket_object" "files" {
  count        = length(local.html_files)
  bucket       = module.s3-web-bucket.web_bucket_id
  key          = local.html_files[count.index]
  source       = format("html/%s", local.html_files[count.index])
  content_type = "text/html"
}