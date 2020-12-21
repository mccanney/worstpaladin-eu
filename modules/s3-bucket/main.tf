terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.22.0"
    }
  }
  required_version = ">= 0.14"
}

locals {
  provisionedDate = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    environmentType = var.environment
    provisionedBy   = "Terraform"
    provisionedOn   = local.provisionedDate
  }

  lifecycle {
    ignore_changes = [
      tags["provisionedOn"]
    ]
  }

}
