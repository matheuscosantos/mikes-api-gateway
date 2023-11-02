provider "aws" {
  region = "us-east-2"
}

data "aws_lambda_function" "mikes_lambda_authorizer" {
  function_name = "mikes_lambda_authorizer"
}

resource "aws_api_gateway_rest_api" "mikes_api_gateway" {
  name = "mikes_api_gateway"
}

resource "aws_api_gateway_resource" "auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.auth_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.auth_resource.id
  http_method             = aws_api_gateway_method.auth_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-2:644237782704:function:mikes_lambda_authorizer/invocations"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.mikes_api_gateway.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = ["arn:aws:cognito-idp:us-east-2:644237782704:userpool/us-east-2_VaSIQn4mE"]
}

resource "aws_api_gateway_deployment" "mikes-api-gateway-deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  stage_name  = "dev"
}

#output "api_gateway_invoke_url" {
#  value = aws_api_gateway_deployment.mikes-api-gateway-deployment.invoke_url
#}
#
#resource "aws_iam_policy" "api_gateway_invoke_lambda_policy" {
#  name        = "APIGatewayInvokeLambdaPolicy"
#  description = "Policy to allow API Gateway to invoke Lambda functions"
#
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Action = "sts:AssumeRole",
#        Effect = "Allow",
#        Resource = "*"
#      },
#      {
#        Effect = "Allow",
#        Action = "lambda:InvokeFunction",
#        Resource = "arn:aws:lambda:us-east-2:644237782704:function/mikes_lambda_authorizer"
#      }
#    ]
#  })
#}

resource "aws_lambda_permission" "mikes_lambda_authorizer_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.mikes_lambda_authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.mikes_api_gateway.execution_arn}/*"
}
