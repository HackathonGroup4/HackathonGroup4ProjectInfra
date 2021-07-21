resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id

  depends_on = [
    aws_api_gateway_rest_api.api_gw
  ]

  triggers = {
    redeployment = filesha256("./api_template.yml")
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_rest_api" "api_gw" {
  name   = "da_api"
  body   = data.template_file.body.rendered
  policy = data.aws_iam_policy_document.api_gw_access_policy.json

  # endpoint_configuration {
  #   types = ["REGIONAL"]
  # }

  depends_on = [
    data.template_file.body
  ]
}

data "template_file" "body" {
  template = file("./api_template.yml")
  vars = {
    api_version      = "0.1"
    api_name         = "da_api"
    contact_email    = "cheongsiuhong@gmail.com"
    api_gateway_role = aws_iam_role.api_gw_role.arn
    region           = data.aws_region.current.name
    invoke_arn       = aws_lambda_function.main.invoke_arn
  }
}

resource "aws_api_gateway_stage" "api_gw_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw.id
  stage_name    = "hackathon"
}

#API GW Access Policy
data "aws_iam_policy_document" "api_gw_access_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["execute-api:/*/*/*"]
  }
}

#IAM Resources
resource "aws_iam_role" "api_gw_role" {
  name               = "APIGW_Role"
  assume_role_policy = data.aws_iam_policy_document.api_assume_role.json
}

data "aws_iam_policy_document" "api_assume_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "api_gw_policy" {
  name   = "APIW_Role_Policy"
  policy = data.aws_iam_policy_document.api_gw_policy_document.json
}

data "aws_iam_policy_document" "api_gw_policy_document" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [aws_lambda_function.main.arn]
  }
}

resource "aws_iam_role_policy_attachment" "api_gw" {
  role       = aws_iam_role.api_gw_role.name
  policy_arn = aws_iam_policy.api_gw_policy.arn
}

resource "aws_iam_role_policy_attachment" "api_gw_cw" {
  role       = aws_iam_role.api_gw_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}