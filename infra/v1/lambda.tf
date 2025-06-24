# Lambda Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.projectName}_lambda_role"
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
}

# Lambda Function
resource "aws_lambda_function" "presigned_url_lambda" {
  function_name = "${var.projectName}_presigned_url"
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      BUCKET_NAME = "presigned-url-fiap-test"
    }
  }
}