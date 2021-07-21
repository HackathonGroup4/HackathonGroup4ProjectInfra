resource "aws_lambda_function" "main" {
  function_name                  = "query_lambda"
  description                    = "Lambda that handles natural language DA queries."
  handler                        = "src/app.handler"
  runtime                        = "python3.8"
  memory_size                    = 128
  timeout                        = 5 // Subject to change
  reserved_concurrent_executions = -1

  depends_on = [
    aws_iam_role_policy_attachment.lambda
  ]

  role             = aws_iam_role.lambda.arn
  filename         = "lambda/dist/da-lambda.zip"
  source_code_hash = filebase64sha256("lambda/dist/da-lambda.zip")
  publish          = true

  # environment {}

  lifecycle {
    ignore_changes = [
      # source_code_hash,
      publish
    ]
  }
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.api_gw.execution_arn
}

resource "aws_iam_role" "lambda" {
  name_prefix = "query-lambda-"
  description = "IAM role for the Query Lambda to assume."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  version = "2012-10-17"
  statement {
    sid     = "AssumedByQueryLambda"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name_prefix = "query-lambda-"
  description = "IAM policy for the Query Lambda."

  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

data "aws_iam_policy_document" "lambda_policy_document" {
  version = "2012-10-17"
  statement {
    sid    = "QueryLambda"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterfaces"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}