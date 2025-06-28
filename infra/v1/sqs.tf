resource "aws_sqs_queue" "s3_notifications_sqs" {
  name = "s3-notifications-sqs"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "arn:aws:sqs:*:*:s3-notifications-sqs",
        "Condition": {
          "ArnEquals": {
           "aws:SourceArn":
              "${aws_s3_bucket.s3_input_bucket.arn}"
           }
        }
      }
    ]
  }
  POLICY

  tags = var.tags
}

resource "aws_sqs_queue" "email_notification_queue" {
  name                      = "${var.projectName}-email-notification-queue"
  receive_wait_time_seconds = 10
  tags = var.tags
}