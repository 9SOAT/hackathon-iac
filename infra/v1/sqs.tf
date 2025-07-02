resource "aws_sqs_queue" "dlq" {
  name                      = "${var.projectName}-video-processing-queue-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "processing_queue" {
  name                       = "${var.projectName}-video-processing-queue"
  visibility_timeout_seconds = 900
  message_retention_seconds  = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.processing_queue.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Sid       = "AllowS3EventNotifications"
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.processing_queue.arn
      Condition = {
        ArnEquals = { "aws:SourceArn" = aws_s3_bucket.s3_input_bucket.arn }
      }
    }]
  })
}

resource "aws_sqs_queue" "dlq-email" {
  name                      = "${var.projectName}-email-notification-queue-dlq"
  message_retention_seconds = 1209600
}

resource "aws_sqs_queue" "email_notification_queue" {
  name = "${var.projectName}-email-notification-queue"

  visibility_timeout_seconds = 900
  message_retention_seconds  = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq-email.arn
    maxReceiveCount     = 5
  })
}
