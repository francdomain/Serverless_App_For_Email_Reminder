resource "aws_route53_record" "s3_bucket" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.subdomain
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_s3_bucket.selected.website_endpoint]
}
