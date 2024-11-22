locals {
  api_url = "https://${aws_api_gateway_rest_api.api_gw.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.api_gw_stage.stage_name}/remindly"
}

locals {
  files = [
    { path = "./serverless_frontend/index.html", key = "index.html", content_type = "text/html" },
    { path = "./serverless_frontend/main.css", key = "main.css", content_type = "text/css" },
    { path = "./serverless_frontend/serverless.js", key = "serverless.js", content_type = "application/javascript" },
    { path = "./serverless_frontend/remindly-logo.png", key = "remindly-logo.png", content_type = "image/png" },
  ]
}
