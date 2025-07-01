# Lambda Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.projectName}_lambda_role-teste-matheus"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Policy para a Lambda acessar o S3 e logs
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# Package the presigned URL Lambda function code
}
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
