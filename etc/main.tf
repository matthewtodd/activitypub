terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.my_policy.json
}

resource "aws_lambda_function" "my_function" {
  filename      = "../src/my_function.zip"
  function_name = "my_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "my_function.handler"

  source_code_hash = filebase64sha256("../src/my_function.zip")

  runtime = "nodejs14.x"
}
