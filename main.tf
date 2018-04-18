provider "aws" {
    version = "~> 1.14"
    region  = "${var.aws_region}"
}

terraform {
    backend "s3" {
        bucket  = "terraform-remote-state-bucket-s3"
        key     = "worstpaladin-eu/terraform.tfstate"
        region  = "eu-west-2"
        encrypt = true
    }
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
    policy = "${file("static/policy.json")}"
    
    website {
        index_document = "index.html"
        error_document = "error.html"
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

resource "aws_s3_bucket_object" "index" {
    bucket       = "${aws_s3_bucket.web.bucket}"
    key          = "index.html"
    source       = "static/index.html"
    content_type = "text/html"
}

resource "aws_s3_bucket_object" "error" {
    bucket       = "${aws_s3_bucket.web.bucket}"
    key          = "error.html"
    source       = "static/error.html"
    content_type = "text/html"
}
