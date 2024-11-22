# Package the Email Lambda function
data "archive_file" "email_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py" # For single file
  output_path = "${path.module}/lambda_function.zip"
}

# Email lambda
resource "aws_lambda_function" "email_lambda" {
  filename      = data.archive_file.email_lambda_zip.output_path
  function_name = "email_reminder_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      ENV = "production"
    }
  }
}

# Package the API Lambda function
data "archive_file" "api_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/api_lambda.py" # For single file
  output_path = "${path.module}/api_lambda.zip"

  depends_on = [null_resource.update_lambda_script]
}

# API lambda
resource "aws_lambda_function" "api_lambda" {
  filename      = data.archive_file.api_lambda_zip.output_path
  function_name = "api_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "api_lambda.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      ENV = "production"
    }
  }
}
