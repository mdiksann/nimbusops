output "api_gateway_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.api.domain_name}"
}

output "assets_bucket" {
  value = aws_s3_bucket.assets.id
}

output "lambda_function_name" {
  value = aws_lambda_function.api.function_name
}