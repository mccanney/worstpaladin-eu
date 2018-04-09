provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

# Route53 DNS zone - worstpaladin.eu
resource "aws_route53_zone" "worstpaladin_eu_zone" {
  name    = "worstpaladin.eu"
  comment = "Route53 DNS zone for worstpaladin.eu"

  tags {
      site        = "worstpaladin.eu"
      environment = "production"
  }
}

# S3 bucket to hold static pages
resource "aws_s3_bucket" "worstpaladin_eu_s3" {
    bucket = "worstpaladin.eu"
    policy = "${file("static/policy.json")}"
    
    website {
        index_document = "index.html"
    }

    tags {
        site        = "worstpaladin.eu"
        environment = "production"
    }
}

# Route53 DNS alias to AWS S3 bucket
resource "aws_route53_record" "worstpaladin_eu_alias" {
    zone_id = "${aws_route53_zone.worstpaladin_eu_zone.zone_id}"
    name    = "worstpaladin.eu"
    type    = "A"

    alias {
        name                   = "${aws_s3_bucket.worstpaladin_eu_s3.bucket_domain_name}"
        zone_id                = "${aws_s3_bucket.worstpaladin_eu_s3.hosted_zone_id}"
        evaluate_target_health = false
    }
}

# Index file
resource "aws_s3_bucket_object" "worstpaladin_eu_index" {
    bucket = "${aws_s3_bucket.worstpaladin_eu_s3.bucket}"
    key    = "index.html"
    source = "${file("static/index.html")}"
}