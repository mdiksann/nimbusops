resource "aws_apigatewayv2_api" "api" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["content-type"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

locals {
  routes = toset([
    "GET /health",
    "GET /test/error",
    "GET /services",
    "GET /services/{id}",
    "POST /services",
    "PUT /services/{id}",
    "DELETE /services/{id}"
  ])
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = local.routes

  api_id    = aws_apigatewayv2_api.api.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = 5000
    throttling_rate_limit    = 10000
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
