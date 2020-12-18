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

locals {
    htmlFiles = [
        "index.html",
        "error.html"
    ]
    provisionedDate = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

resource "aws_route53_zone" "zone" {
    name              = var.domain
    comment           = "Route53 DNS zone for ${var.domain}"
    delegation_set_id = var.delegation_set

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

resource "aws_s3_bucket" "web" {
    bucket = var.domain
    policy = templatefile("policies/bucket-policy.json", { domain = var.domain })

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

resource "aws_route53_record" "alias" {
    zone_id = aws_route53_zone.zone.zone_id
    name    = var.domain
    type    = "A"

    alias {
        name                   = aws_s3_bucket.web.website_domain
        zone_id                = aws_s3_bucket.web.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_s3_bucket_object" "files" {
    count        = length(local.htmlFiles)
    bucket       = aws_s3_bucket.web.bucket
    key          = local.htmlFiles[count.index]
    source       = format("html/%s", local.htmlFiles[count.index])
    content_type = "text/html"
}
