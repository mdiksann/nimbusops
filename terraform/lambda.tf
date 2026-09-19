data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../app/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}-api"
  retention_in_days = 7
}

resource "aws_lambda_function" "api" {
  function_name = "${local.name_prefix}-api"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  memory_size = 128
  timeout     = 10

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.services.name
      ASSETS_BUCKET  = aws_s3_bucket.assets.id
      APP_NAME_PARAM = aws_ssm_parameter.app_name.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}
