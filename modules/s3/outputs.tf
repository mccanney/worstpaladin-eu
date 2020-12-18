output "website_domain" {
  value = aws_s3_bucket.web.website_domain
}

output "hosted_zone_id" {
  value = aws_s3_bucket.web.hosted_zone_id
}
