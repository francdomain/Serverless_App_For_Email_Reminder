# Create cloudwatch log group
resource "aws_cloudwatch_log_group" "log_group_for_sfn" {
  name = "log_group_for_sfn"
}

# Create State Machine in step function
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "RemindLy"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
  {
    "Comment": "RemindLy - using Lambda for email.",
    "StartAt": "Timer",
    "States": {
      "Timer": {
        "Type": "Wait",
        "SecondsPath": "$.waitSeconds",
        "Next": "Email"
      },
      "Email": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "${aws_lambda_function.email_lambda.arn}",
          "Payload": {
            "Input.$": "$"
          }
        },
        "Next": "NextState"
      },
      "NextState": {
        "Type": "Pass",
        "End": true
      }
    }
  }
  EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.log_group_for_sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}
