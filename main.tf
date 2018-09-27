provider "aws" {
    version = "~> 1.14"
    region  = "${var.aws_region}"
}

provider "template" {
    version = "~> 1.0"
}

terraform {
    required_version = "~> 0.11"

    backend "s3" {
        bucket  = "terraform-remote-state-bucket-s3"
        key     = "worstpaladin-eu/terraform.tfstate"
        region  = "eu-west-2"
        encrypt = true
    }
}

data "template_file" "bucket_policy" {
    template = "${file("policies/bucket-policy.json")}"

    vars {
      domain = "${var.domain}"
    }
}

locals {
    html_files = [
        "index.html",
        "error.html"
    ]
}

resource "aws_route53_zone" "zone" {
    name              = "${var.domain}"
    comment           = "Route53 DNS zone for ${var.domain}"
    delegation_set_id = "${var.delegation_set}"

    tags {
        site        = "${var.domain}"
        environment = "production"
    }
}

resource "aws_s3_bucket" "web" {
    bucket = "${var.domain}"
    policy = "${data.template_file.bucket_policy.rendered}"

    website {
        index_document = "${local.html_files[0]}"
        error_document = "${local.html_files[1]}"
    }

    tags {
        site        = "${var.domain}"
        environment = "production"
    }
}

resource "aws_route53_record" "alias" {
    zone_id = "${aws_route53_zone.zone.zone_id}"
    name    = "${var.domain}"
    type    = "A"

    alias {
        name                   = "${aws_s3_bucket.web.website_domain}"
        zone_id                = "${aws_s3_bucket.web.hosted_zone_id}"
        evaluate_target_health = false
    }
}

resource "aws_s3_bucket_object" "files" {
    count        = "${length(local.html_files)}"
    bucket       = "${aws_s3_bucket.web.bucket}"
    key          = "${local.html_files[count.index]}"
    source       = "${format("html/%s", local.html_files[count.index])}"
    content_type = "text/html"
}
