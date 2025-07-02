resource "aws_sns_topic" "complete" {
  name = aws_sqs_queue.email_notification_queue.name
}
