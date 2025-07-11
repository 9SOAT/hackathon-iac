module "main" {
  source = "../../infra/v1"
  tags = {
    Environment = "homolog",
    Team        = "9soat"
    Terraform   = "true"
  }
  verified_email = var.verified_email
}

variable "verified_email" {
    type        = string
    description = "Email address to be verified for the Cognito User Pool"
}

output "api_gateway_url" {
  value = module.main.api_endpoint
}

output "s3_input_bucket_name" {
  value = module.main.input_bucket_name
}

output "sqs_queue_url" {
  value = module.main.queue_url
}

output "cognito_client_id" {
  value = module.main.client_id
}
