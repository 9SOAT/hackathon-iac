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


/*
data "aws_region" "current" {
  current = true
}

data "aws_caller_identity" "current" {}

resource "aws_apigatewayv2_integration" "int" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  integration_method = "POST"
  integration_uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:function:${var.lambda_name}/invocations"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "GET example"
  target = "integrations/${aws_apigatewayv2_integration.int.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
}
*/


resource "aws_apigatewayv2_integration" "test" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "HTTP_PROXY"
  connection_type = "INTERNET"
  integration_method = "GET"
  integration_uri = "https://reqbin.com/echo/get/json"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "GET /test"
  target = "integrations/${aws_apigatewayv2_integration.test.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id
}

resource "aws_apigatewayv2_stage" "example" {
  api_id = aws_apigatewayv2_api.gateway.id
  name   = "dev"
  auto_deploy = true # Automatically deploy changes to the stage
}