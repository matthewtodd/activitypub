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

  role = aws_iam_role.iam_for_lambda.arn
}

resource "aws_cloudwatch_log_group" "my_function" {
  name = "/aws/lambda/${aws_lambda_function.my_function.function_name}"

  retention_in_days = 3
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.my_policy.json
}

data "aws_iam_policy_document" "my_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "lambda_logging" {
  name   = "lambda_logging"
  policy = data.aws_iam_policy_document.lambda_logging.json
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:putLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
