output "website_domain" {
  value = module.s3-web-bucket.website_domain
}

output "hosted_zone_id" {
  value = module.s3-web-bucket.hosted_zone_id
}
