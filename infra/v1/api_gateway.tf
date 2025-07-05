resource "aws_apigatewayv2_api" "gateway" {
  name = "${var.projectName}_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [split("|", awscc_cognito_user_pool_client.client.id)[1]]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

# Permitir API Gateway chamar a Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

# API Gateway Integration com Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.presigned_url_lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Route para a Lambda
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "POST /presigned-url"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
}

resource "aws_apigatewayv2_stage" "example" {
  api_id = aws_apigatewayv2_api.gateway.id
  name   = "dev"
  auto_deploy = true # Automatically deploy changes to the stage
}

# Permitir API Gateway chamar a Lambda
resource "aws_lambda_permission" "apigw_invoke_listing" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.listing_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

# API Gateway Integration com Lambda
resource "aws_apigatewayv2_integration" "lambda_integration_listing" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.listing_lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Route para a Lambda
resource "aws_apigatewayv2_route" "lambda_route_listing" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "GET /videos"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_listing.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
}