output "api_endpoint" {
  value = aws_apigatewayv2_api.gateway.api_endpoint
}

output "input_bucket_name" {
  value = aws_s3_bucket.s3_input_bucket.bucket
}

output "queue_url" {
  value = aws_sqs_queue.s3_notifications_sqs.id
}

output "client_id" {
  value = awscc_cognito_user_pool_client.client.id
}