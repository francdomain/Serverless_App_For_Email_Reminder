resource "time_sleep" "wait_for_email" {
  depends_on = [
    aws_ses_email_identity.sender_email,
    aws_ses_email_identity.recipient_email
  ]

  create_duration = "30s"
}

# The API Gateway configuration below will support CORS, allowing cross-origin requests from browsers.

resource "aws_api_gateway_rest_api" "api_gw" {
  name = "remindly"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [time_sleep.wait_for_email]
}

resource "aws_api_gateway_resource" "api_gw_rs" {
  parent_id   = aws_api_gateway_rest_api.api_gw.root_resource_id
  path_part   = "remindly"
  rest_api_id = aws_api_gateway_rest_api.api_gw.id

}

# For cross-origin requests (CORS), the OPTIONS method is essential to handle preflight requests.
# Used by browsers for CORS preflight requests to check if the server allows a specific cross-origin POST (or other HTTP) request.
# Does not process or forward the actual POST request payload.
# Typically returns response headers that define allowed methods, origins, and headers. e.g,
# ```
# HTTP/1.1 200 OK
# Access-Control-Allow-Origin: *
# Access-Control-Allow-Methods: POST, GET, OPTIONS
# Access-Control-Allow-Headers: Content-Type
# ```

resource "aws_api_gateway_method" "api_gw_options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gw.id
  resource_id   = aws_api_gateway_resource.api_gw_rs.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  depends_on = [
    aws_api_gateway_rest_api.api_gw,
    aws_api_gateway_resource.api_gw_rs
  ]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.api_gw_rs.id
  http_method = aws_api_gateway_method.api_gw_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.api_gw_rs.id
  http_method = aws_api_gateway_method.api_gw_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.api_gw_rs.id
  http_method = aws_api_gateway_integration.options_integration.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}


## Configuration below is essential for same-origin requests (requests from the same domain, protocol, and port)
# Handles the actual payload and processes the request logic (e.g., invoking a Lambda function or updating a database).
# Required to process client data and send back a meaningful response.

resource "aws_api_gateway_method" "api_gw_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gw.id
  resource_id   = aws_api_gateway_resource.api_gw_rs.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gw.id
  resource_id             = aws_api_gateway_resource.api_gw_rs.id
  http_method             = aws_api_gateway_method.api_gw_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_method_response" "post_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.api_gw_rs.id
  http_method = aws_api_gateway_method.api_gw_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.api_gw_rs.id
  http_method = aws_api_gateway_integration.post_integration.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Define the Deployment
resource "aws_api_gateway_deployment" "api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id

  depends_on = [
    aws_api_gateway_integration.post_integration,
    # aws_api_gateway_integration.options_integration
  ]
}

# Define the Stage explicitly
resource "aws_api_gateway_stage" "api_gw_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api_gw.id
  deployment_id = aws_api_gateway_deployment.api_gw_deployment.id

  description = "Production stage for API"
  variables = {
    lambdaAlias = "prod"
  }
}


# Dynamically place the API endpoint in serverless.js
resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = <<EOT
      sed -i.bak "s|var API_ENDPOINT = .*;|var API_ENDPOINT = '${local.api_url}';|" ./serverless_frontend/serverless.js
    EOT
  }

  depends_on = [
    aws_api_gateway_rest_api.api_gw,
    aws_api_gateway_stage.api_gw_stage
  ]
}
