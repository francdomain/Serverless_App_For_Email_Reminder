import boto3
import json

# Email address to send emails from (verified in SES)
FROM_EMAIL_ADDRESS = 'fncdomain06@gmail.com'  # Update with your SES-verified email address

# Initialize the SES client
ses = boto3.client('ses')

def lambda_handler(event, context):
    """
    Lambda function to send emails using Amazon SES.
    The event is expected to contain email and message fields.
    """
    try:
        # Log the received event
        print("Received event: " + json.dumps(event))

        # Extract the email and message from the input event
        email = event['Input']['email']
        message = event['Input']['message']

        # Validate inputs
        if not email or not message:
            raise ValueError("Email and message must be provided.")

        # Send email using SES
        ses.send_email(
            Source=FROM_EMAIL_ADDRESS,
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'Reminder from Remindly'},
                'Body': {'Text': {'Data': message}}
            }
        )

        print("Email sent successfully!")
        return {"status": "Success", "message": "Email sent successfully!"}

    except Exception as e:
        # Log and return error details
        print(f"Error occurred: {str(e)}")
        return {"status": "Failure", "error": str(e)}