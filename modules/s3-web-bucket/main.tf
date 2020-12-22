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

resource "aws_s3_bucket" "web" {
  bucket = var.bucket_name
  policy = templatefile("${path.module}/bucket-policy.json", { bucket_name = var.bucket_name })

  website {
    index_document = var.index_file
    error_document = var.error_file
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
