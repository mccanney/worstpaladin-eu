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

# Route53 DNS alias to AWS S3 bucket
resource "aws_route53_record" "worstpaladin_eu_alias" {
    zone_id = "${aws_route53_zone.worstpaladin_eu_zone.zone_id}"
    name    = "worstpaladin.eu"
    type    = "A"

    alias {
        name                   = "${aws_s3_bucket.worstpaladin_eu_s3.dns_name}"
        zone_id                = "${aws_s3_bucket.worstpaladin_eu_s3.zone_id}"
        evaluate_target_health = false
    }
}