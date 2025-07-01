output "api_endpoint" {
  value = aws_apigatewayv2_api.gateway.api_endpoint
}

output "client_id" {
  value = awscc_cognito_user_pool_client.client.id
}
output "input_bucket_name" {
  description = "Name of the input S3 bucket"
  value       = aws_s3_bucket.s3_input_bucket.bucket
}

output "output_bucket" {
  description = "Name of the output S3 bucket"
  value       = aws_s3_bucket.s3_output_bucket.bucket
}

output "queue_url" {
  description = "URL of the SQS processing queue"
  value = aws_sqs_queue.processing_queue.name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB jobs table"
  value       = aws_dynamodb_table.jobs.name
}
