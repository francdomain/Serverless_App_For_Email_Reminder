
resource "aws_ses_email_identity" "sender_email" {
  email = var.sender_email
}

resource "aws_ses_email_identity" "recipient_email" {
  email = var.recipient_email
}
