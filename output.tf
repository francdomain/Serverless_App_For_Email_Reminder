output "api_stage_url" {
  value       = "https://${aws_api_gateway_rest_api.api_gw.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.api_gw_stage.stage_name}/remindly"
  description = "The URL for prod stage of the API Gateway"
}

output "sm_arn" {
  value = aws_sfn_state_machine.sfn_state_machine.arn
}

output "bucket_endpoint" {
  value = aws_s3_bucket.static_website.website_endpoint
}
