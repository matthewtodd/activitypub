terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

data "archive_file" "my_function" {
  type        = "zip"
  source_file = "${path.module}/../src/my_function.js"
  output_path = "${path.module}/../src/my_function.zip"
}

resource "aws_lambda_function" "my_function" {
  function_name = "my_function"

  filename         = data.archive_file.my_function.output_path
  source_code_hash = data.archive_file.my_function.output_base64sha256

  runtime = "nodejs14.x"
  handler = "my_function.handler"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "my_function" {
  name = "/aws/lambda/${aws_lambda_function.my_function.function_name}"

  retention_in_days = 3
}

resource "aws_iam_role" "lambda_exec" {
  name               = "serverless_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

data "aws_iam_policy_document" "lambda_exec" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "my_api" {
  name          = "my_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "my_api" {
  api_id = aws_apigatewayv2_api.my_api.id

  name        = "my_api_stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "my_function" {
  api_id = aws_apigatewayv2_api.my_api.id

  integration_uri    = aws_lambda_function.my_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "my_function" {
  api_id = aws_apigatewayv2_api.my_api.id

  route_key = "GET /my_function"
  target    = "integrations/${aws_apigatewayv2_integration.my_function.id}"
}

resource "aws_lambda_permission" "my_api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.my_api.execution_arn}/*/*"
}

output "base_url" {
  value = aws_apigatewayv2_stage.my_api.invoke_url
}
