data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

data "aws_s3_bucket" "selected" {
  bucket = var.bucket_name

  depends_on = [
    aws_s3_object.static_files
  ]
}
