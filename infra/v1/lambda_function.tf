
# resource "aws_lambda_function" "processor" {
#   function_name    = "video-processor-${var.projectName}"
#   filename         = "/home/matheusfrancesquini/Documentos/FIAP/HackTom/hackathon-lambda-video-frame/build/deployment-package.zip"
#   source_code_hash = filebase64sha256("/home/matheusfrancesquini/Documentos/FIAP/HackTom/hackathon-lambda-video-frame/build/deployment-package.zip")
#   handler       = "lambda_processor.lambda_handler"
#   runtime       = "python3.11"
#   timeout          = 900
#   memory_size      = 1024
#   layers           = ["arn:aws:lambda:us-east-1:897722698720:layer:ffmpeg:1"]
#   role          = aws_iam_role.lambda_exec.arn


#   environment {
#     variables = {
#       INPUT_BUCKET  = var.input_bucket_name
#       OUTPUT_BUCKET = var.output_bucket_name
#       DDB_TABLE     = var.ddb_table_name
#       SNS_TOPIC_ARN = var.sns_topic_name
#     }
#   }
# }
# resource "aws_lambda_event_source_mapping" "sqs2lambda" {
#   event_source_arn = aws_sqs_queue.processing_queue.arn
#   function_name    = aws_lambda_function.processor.arn
#   batch_size       = 1
#   enabled          = true
# }

# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda-processor-role-${var.projectName}"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
#   })
# }
# resource "aws_iam_policy_attachment" "basic_exec" {
#   name       = "lambda-basic-exec-${var.projectName}"
#   roles      = [aws_iam_role.lambda_exec.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
# resource "aws_iam_role_policy" "custom" {
#   name = "lambda-custom-policy-${var.projectName}"
#   role = aws_iam_role.lambda_exec.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       { Sid = "S3Access", Effect = "Allow",
#         Action = ["s3:ListBucket","s3:GetObject","s3:HeadObject","s3:PutObject"],
#         Resource = [
#           aws_s3_bucket.s3_input_bucket.arn, 
#           "${aws_s3_bucket.s3_input_bucket.arn}/*", 
#           aws_s3_bucket.s3_output_bucket.arn, 
#           "${aws_s3_bucket.s3_output_bucket.arn}/*"]
#         },
#       { Sid = "SQSAccess", Effect = "Allow", Action = ["sqs:ReceiveMessage","sqs:DeleteMessage","sqs:GetQueueAttributes"], Resource = aws_sqs_queue.processing_queue.arn },
#       { Sid = "DDBAccess", Effect = "Allow", Action = ["dynamodb:PutItem","dynamodb:UpdateItem"], Resource = aws_dynamodb_table.jobs.arn },
#       { Sid = "SNSAccess", Effect = "Allow", Action = "sns:Publish", Resource = aws_sns_topic.complete.arn }
#     ]
#   })
# }

