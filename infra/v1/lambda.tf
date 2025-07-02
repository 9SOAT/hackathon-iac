# Package the presigned URL Lambda function code
data "archive_file" "dummy_presigned_url_zip" {
  type        = "zip"
  output_path = "${path.module}/../../lambdas/dummy/presigned_url.zip"
  source_dir = "${path.module}/../../lambdas/dummy/presigned_url"
}

# Lambda Function
resource "aws_lambda_function" "presigned_url_lambda" {
  function_name = "${var.projectName}_presigned_url"
  filename         = data.archive_file.dummy_presigned_url_zip.output_path
  source_code_hash = data.archive_file.dummy_presigned_url_zip.output_base64sha256
  handler       = "presigned_dummy.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      BUCKET_NAME = "presigned-url-fiap-test"
    }
  }
  tags = var.tags
}

# Package the notification lambda function code
data "archive_file" "dummy_email_notification_zip" {
  type        = "zip"
  output_path = "${path.module}/../../lambdas/dummy/email_notification.zip"
  source_dir = "${path.module}/../../lambdas/dummy/email_notification"
}

resource "aws_lambda_function" "email_notification_lambda" {
  function_name = "${var.projectName}_email_notification"
  filename         = data.archive_file.dummy_email_notification_zip.output_path
  source_code_hash = data.archive_file.dummy_email_notification_zip.output_base64sha256
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.notification_lambda_role.arn
  tags = var.tags
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.email_notification_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.email_notification_lambda.arn
  batch_size       = 1
}

# Package the listing lambda function code
data "archive_file" "listing_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/../../lambdas/dummy/listing_lambda.zip"
  source_dir  = "${path.module}/../../lambdas/dummy/listing_lambda"
}

resource "aws_lambda_function" "listing_lambda" {
  function_name    = "${var.projectName}_listing_lambda"
  filename         = data.archive_file.listing_lambda_zip.output_path
  source_code_hash = data.archive_file.listing_lambda_zip.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.jobs.name
    }
  }
  tags = var.tags
}

data "archive_file" "dummy_processor_zip" {
  type        = "zip"
  output_path = "${path.module}/../../lambdas/dummy/process_video.zip"
  source_dir = "${path.module}/../../lambdas/dummy/process_video"
}

resource "aws_lambda_function" "processor" {

  function_name    = "${var.projectName}_video_processor"
  filename         = data.archive_file.dummy_processor_zip.output_path
  source_code_hash = data.archive_file.dummy_processor_zip.output_base64sha256
  handler       = "lambda_processor.lambda_handler"
  runtime       = "python3.11"
  timeout          = 900
  memory_size      = 1024
  layers           = ["arn:aws:lambda:us-east-1:897722698720:layer:ffmpeg:1"]
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      INPUT_BUCKET  = var.input_bucket_name
      OUTPUT_BUCKET = var.output_bucket_name
      DDB_TABLE     = var.ddb_table_name
      SNS_TOPIC_ARN = aws_sns_topic.complete.arn
    }
  }
}
resource "aws_lambda_event_source_mapping" "sqs2lambda" {
  event_source_arn = aws_sqs_queue.processing_queue.arn
  function_name    = aws_lambda_function.processor.arn
  batch_size       = 1
  enabled          = true
}
