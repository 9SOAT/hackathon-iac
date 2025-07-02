resource "aws_s3_bucket" "s3_input_bucket" {
  bucket = var.input_bucket_name
  tags = var.tags
}

resource "aws_s3_bucket" "s3_output_bucket" {
  bucket = var.output_bucket_name
  tags = var.tags
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = aws_s3_bucket.s3_input_bucket.id

  queue {
    events    = ["s3:ObjectCreated:*"]
    queue_arn = aws_sqs_queue.processing_queue.arn
  }
  depends_on = [aws_sqs_queue_policy.allow_s3]
}