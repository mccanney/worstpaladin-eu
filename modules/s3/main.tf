terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.22.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
  }
  required_version = ">= 0.14"
}

locals {
  htmlFiles = [
    "index.html",
    "error.html"
  ]
  provisionedDate = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

resource "random_string" "bucket_name" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "web" {
  bucket = var.domain
  policy = templatefile("${path.module}/bucket-policy.json", { domain = var.domain })

  website {
    index_document = local.htmlFiles[0]
    error_document = local.htmlFiles[1]
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

resource "aws_s3_bucket_object" "html_files" {
  count = length(local.htmlFiles)

  bucket       = aws_s3_bucket.web.bucket
  key          = local.htmlFiles[count.index]
  source       = format("${path.module}/html/%s", local.htmlFiles[count.index])
  content_type = "text/html"
}

resource "aws_s3_bucket" "lambda" {
  bucket = "lambda-bucket-${random_string.bucket_name.result}"
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
