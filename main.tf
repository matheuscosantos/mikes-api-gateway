provider "aws" {
  region = "us-east-2"
}

data "aws_lambda_function" "mikes_lambda_authorizer" {
  function_name = "mikes_lambda_authorizer"
}

resource "aws_api_gateway_rest_api" "mikes_api_gateway" {
  name = "mikes_api_gateway"
}

resource "aws_api_gateway_request_validator" "validator" {
  name                        = "validator"
  rest_api_id                 = aws_api_gateway_rest_api.mikes_api_gateway.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_resource" "auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "customer_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "customers"
}

resource "aws_api_gateway_resource" "product_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "products"
}

resource "aws_api_gateway_resource" "variable_customer_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_resource.customer_resource.id
  path_part   = "{cpf}"
}

resource "aws_api_gateway_resource" "order_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "orders"
}


resource "aws_api_gateway_resource" "variable_product_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_resource.product_resource.id
  path_part   = "category"
}

resource "aws_api_gateway_resource" "variable_id_product_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_resource.product_resource.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "orders_payment_order_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "{orderId}"
}

resource "aws_api_gateway_resource" "orders_payment_webhook_process_resource" {
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.mikes_api_gateway.root_resource_id
  path_part   = "process"
}

resource "aws_api_gateway_method" "auth_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.auth_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_variable_customer_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.variable_customer_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.path.cpf" = true
  }
}

resource "aws_api_gateway_method" "get_orders" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "post_orders" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_models = {
    "application/json" = "Empty"
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_method" "get_variable_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.variable_product_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.querystring.value"  = true,
    "method.request.querystring.active" = true
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_method" "post_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.product_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_models = {
    "application/json" = "Empty"
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_method" "put_variable_customer_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.variable_id_product_resource.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.path.id" = true
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_method" "delete_variable_customer_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.variable_id_product_resource.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.path.id" = true
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}


resource "aws_api_gateway_method" "post_customer_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.customer_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_models = {
    "application/json" = "Empty"
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_method" "get_orders_payment_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.orders_payment_order_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  type          = "HTTP_PROXY"
  request_models = {
    "application/json" = "Empty"
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_method" "post_orders_payment_webhook_process_method" {
  rest_api_id   = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id   = aws_api_gateway_resource.orders_payment_webhook_process_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  type          = "HTTP_PROXY"
  request_models = {
    "application/json" = "Empty"
  }

  request_parameters = {
    "method.request.path.order" = true
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.auth_resource.id
  http_method             = aws_api_gateway_method.auth_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-2:644237782704:function:mikes_lambda_authorizer/invocations"
}

resource "aws_api_gateway_integration" "get_customer_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.variable_customer_resource.id
  http_method             = aws_api_gateway_method.get_variable_customer_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/customers/{cpf}"
  content_handling        = "CONVERT_TO_TEXT"
  request_parameters      = {
    "integration.request.path.cpf" = "method.request.path.cpf"
  }
}

resource "aws_api_gateway_integration" "post_customer_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.customer_resource.id
  http_method             = aws_api_gateway_method.post_customer_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"

  uri              = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/customers"
  content_handling = "CONVERT_TO_TEXT"

  request_templates = {
    "application/json" = jsonencode({
      "cpf"   = "$input.json('$.cpf')",
      "name"  = "$input.json('$.name')",
      "email" = "$input.json('$.email')"
    })
  }
}

resource "aws_api_gateway_integration" "get_orders_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.order_resource.id
  http_method             = aws_api_gateway_method.get_orders.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/orders"
  content_handling        = "CONVERT_TO_TEXT"  
}

resource "aws_api_gateway_integration" "post_orders_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.order_resource.id
  http_method             = aws_api_gateway_method.post_orders.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"

  uri = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/orders"
  content_handling        = "CONVERT_TO_TEXT"

  request_templates = {
    "application/json" = jsonencode({
      cpf   = "$input.path('$.cpf')",
      items = "$input.path('$.items')"
    })
  }
}

resource "aws_api_gateway_integration" "get_product_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.variable_product_resource.id
  http_method             = aws_api_gateway_method.get_variable_product_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/products/category"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "post_product_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.product_resource.id
  http_method             = aws_api_gateway_method.post_product_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"

  uri              = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/products"
  content_handling = "CONVERT_TO_TEXT"

  request_templates = {
    "application/json" = jsonencode({
      "name"        = "$input.json('$.name')",
      "description" = "$input.json('$.description')",
      "price"       = "$input.json('$.price')",
      "category"    = "$input.json('$.category')"
    })
  }
}

resource "aws_api_gateway_integration" "put_product_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.variable_id_product_resource.id
  http_method             = aws_api_gateway_method.put_variable_customer_method.http_method
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"

  uri              = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/products/{id}"
  content_handling = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_api_gateway_integration" "delete_product_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.variable_id_product_resource.id
  http_method             = aws_api_gateway_method.delete_variable_customer_method.http_method
  integration_http_method = "DELETE"
  type                    = "HTTP_PROXY"

  uri              = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/products/{id}"
  content_handling = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_api_gateway_integration" "get_orders_payment_order" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.orders_payment_order_resource.id
  http_method             = aws_api_gateway_method.get_orders_payment_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/orders-payment/order/{orderId}"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_integration" "get_orders_payment_change_status_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mikes_api_gateway.id
  resource_id             = aws_api_gateway_resource.orders_payment_webhook_process_resource.id
  http_method             = aws_api_gateway_method.post_orders_payment_webhook_process_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri = "http://mikes-ecs-alb-1631856801.us-east-2.elb.amazonaws.com:8080/orders-payment/webhook/process"
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.mikes_api_gateway.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = ["arn:aws:cognito-idp:us-east-2:644237782704:userpool/us-east-2_2BLwlHbmP"]
}

resource "aws_api_gateway_deployment" "mikes-api-gateway-deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_integration.get_customer_integration]
  rest_api_id = aws_api_gateway_rest_api.mikes_api_gateway.id
  stage_name  = "dev"
}

resource "aws_lambda_permission" "mikes_lambda_authorizer_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.mikes_lambda_authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.mikes_api_gateway.execution_arn}/*"
}
