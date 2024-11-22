variable "region" {
  description = "AWS region where the API Gateway is deployed"
  type        = string
}

variable "stage_name" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "my domain name"
}

variable "subdomain" {
  type        = string
  description = "my sub domain"
}

variable "sender_email" {
  type = string
}

variable "recipient_email" {
  type = string
}

# When you configure an Amazon S3 bucket for website hosting,
# you must give the bucket the same name as the record that you want to use to route traffic to the bucket.
# For example, if you want to route traffic for example.com to an S3 bucket that is configured for website hosting,
# the name of the bucket must be example.com.

variable "bucket_name" {
  type    = string
  default = "remindly13579"
}
