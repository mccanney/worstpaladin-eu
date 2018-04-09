provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.aws_region}"
}

# S3 bucket to hold static pages
resource "aws_s3_bucket" "worstpaladin_eu_s3" {
    bucket = "worstpaladin.eu"
    policy = ""
    
    website {
        index_document = "index.html"
    }

    tags {
        site        = "worstpaladin.eu"
        environment = "production"
    }
}

# Index file
resource "aws_s3_bucket_object" "worstpaladin_eu_index" {
    bucket = "${aws_s3_bucket.worstpaladin_eu_s3.bucket}"
    key    = "index.html"
    source = "static\index.html"
}