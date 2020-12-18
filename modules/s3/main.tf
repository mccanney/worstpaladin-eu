terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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

resource "aws_s3_bucket" "web" {
  bucket = var.domain
  policy = templatefile("${path.module}/bucket-policy.json", { domain = var.domain })

  website {
    index_document = local.htmlFiles[0]
    error_document = local.htmlFiles[1]
  }

  tags = {
    provisionedBy = "Terraform"
    provisionedOn = local.provisionedDate
  }

  lifecycle {
    ignore_changes = [
      tags["provisionedOn"]
    ]
  }
}

resource "aws_s3_bucket_object" "files" {
  count        = length(local.htmlFiles)
  bucket       = aws_s3_bucket.web.bucket
  key          = local.htmlFiles[count.index]
  source       = format("html/%s", local.htmlFiles[count.index])
  content_type = "text/html"
}
