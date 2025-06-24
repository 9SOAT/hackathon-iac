resource "aws_lambda_function" "presigned_url_lambda" {
  function_name = "${var.projectName}_presigned_url"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  
  # Cria função vazia, sem código ainda
  filename            = null
  source_code_hash    = null
  publish             = false

  environment {
    variables = {
      BUCKET_NAME = "presigned-url-fiap-test"
    }
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}