import boto3
import json
import decimal

# Updated State Machine ARN for Remindly
SM_ARN = "__SM_ARN__"  # Replace with the actual ARN for Remindly

sm = boto3.client('stepfunctions')

def lambda_handler(event, context):
    # Log the received event
    print("Received event: " + json.dumps(event))

    # Check if 'body' exists in the event
    if 'body' not in event:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "No body in event"})
        }

    try:
        # Load data from API Gateway
        data = json.loads(event['body'])
        data['waitSeconds'] = int(data.get('waitSeconds', 0))  # Safely access 'waitSeconds'

        # Validate required parameters
        checks = [
            'waitSeconds' in data,
            isinstance(data['waitSeconds'], int),
            'message' in data
        ]

        # Return error if validation fails
        if False in checks:
            response = {
                "statusCode": 400,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
                    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
                },
                "body": json.dumps({"Status": "Failure", "Reason": "Input validation failed"}, cls=DecimalEncoder)
            }
        else:
            # Start the Step Functions state machine and return success response
            sm.start_execution(stateMachineArn=SM_ARN, input=json.dumps(data, cls=DecimalEncoder))
            response = {
                "statusCode": 200,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
                    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
                },
                "body": json.dumps({"Status": "Success"}, cls=DecimalEncoder)
            }

        return response

    except Exception as e:
        # Log error and return internal server error response
        print(f"Error processing request: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Internal server error", "error": str(e)})
        }

# Custom JSON encoder to handle Decimal types
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            print(f"Converting Decimal to int: {obj}")  # Debug log for Decimal conversion
            return int(obj)
        return super(DecimalEncoder, self).default(obj)