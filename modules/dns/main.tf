terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.14"
}

locals {
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

resource "aws_route53_record" "alias" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.website_domain
    zone_id                = var.hosted_zone_id
    evaluate_target_health = false
  }
}
