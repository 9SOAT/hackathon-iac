# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Lambda Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.projectName}_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Policy para a Lambda acessar o S3 e logs
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# SES Email Identity
data "aws_iam_policy_document" "ses_send_templated_email_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendTemplatedEmail"
    ]
    resources = [
      aws_ses_email_identity.semplates_email_identity.arn,
      aws_ses_template.success_email_template.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ses:GetTemplate",
    ]
    resources = [aws_ses_template.success_email_template.arn]
  }
}

resource "aws_iam_role" "notification_lambda_role" {
  name = "${var.projectName}_notification_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "notification_lambda_logs" {
  role       = aws_iam_role.notification_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "notification_lambda_sqs" {
  role       = aws_iam_role.notification_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_policy" "ses_send_templated_email" {
  name        = "SESSendTemplatedEmailPolicy"
  description = "Policy to allow SES sendTemplatedEmail only."
  policy      = data.aws_iam_policy_document.ses_send_templated_email_policy.json
}

resource "aws_iam_role_policy_attachment" "ses_notification_lambda_policy_attach" {
  role       = aws_iam_role.notification_lambda_role.name
  policy_arn = aws_iam_policy.ses_send_templated_email.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-processor-role-${var.projectName}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_policy_attachment" "basic_exec" {
  name       = "lambda-basic-exec-${var.projectName}"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy" "custom" {
  name = "lambda-custom-policy-${var.projectName}"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Sid = "S3Access", Effect = "Allow",
        Action = ["s3:ListBucket","s3:GetObject","s3:HeadObject","s3:PutObject"],
        Resource = [
          aws_s3_bucket.s3_input_bucket.arn, 
          "${aws_s3_bucket.s3_input_bucket.arn}/*", 
          aws_s3_bucket.s3_output_bucket.arn, 
          "${aws_s3_bucket.s3_output_bucket.arn}/*"]
        },
      { Sid = "SQSAccess", Effect = "Allow", Action = ["sqs:ReceiveMessage","sqs:DeleteMessage","sqs:GetQueueAttributes"], Resource = aws_sqs_queue.processing_queue.arn },
      { Sid = "DDBAccess", Effect = "Allow", Action = ["dynamodb:PutItem","dynamodb:UpdateItem"], Resource = aws_dynamodb_table.jobs.arn },
      { Sid = "SNSAccess", Effect = "Allow", Action = "sns:Publish", Resource = aws_sns_topic.complete.arn }
    ]
  })
}

