locals {
  name_tag       = title(replace(var.name, "-", " "))
  stage_name_tag = title(replace(var.stage_name, "-", " "))
  functions_map  = { for f in var.functions : f.name => f.invoke_arn }
}

### API Gateway Core ###

resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description

  body = templatefile(var.openapi_filepath, local.functions_map)

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = local.name_tag
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    deploy = sha256(aws_api_gateway_rest_api.this.body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this.arn
    format = jsonencode({
      Response : {
        Status : "$context.status",
        "Response Length" : "$context.responseLength",
        "Response Latency" : "$context.responseLatency",
      },
      Request : {
        ID : "$context.requestId",
        "Request Time" : "$context.requestTime",
        Protocol : "$context.protocol",
        "HTTP Method" : "$context.httpMethod",
        "Resource Path" : "$context.path",
        "Domain Name" : "$context.domainName",
        "Domain Prefix" : "$context.domainPrefix",
      },
      Identity : {
        "Source IP" : "$context.identity.sourceIp",
        "User Agent" : "$context.identity.userAgent",
        User : "$context.identity.user",
        Caller : "$context.identity.caller",
      },
      Error : {
        Message : "$context.error.message",
        "Response Type" : "$context.error.responseType",
      },
      Integration : {
        "Request ID" : "$context.integration.requestId",
        Status : "$context.integration.status",
        Latency : "$context.integration.latency",
        Error : "$context.integration.error",
        "Integration Status" : "$context.integration.integrationStatus",
      },
      AWS : {
        "Account ID" : "$context.accountId",
        "API ID" : "$context.apiId",
        Stage : "$context.stage",
        "Route Key" : "$context.routeKey",
      },
    })
  }

  tags = {
    Name = local.stage_name_tag
  }

  depends_on = [
    aws_api_gateway_account.this,
    aws_cloudwatch_log_group.this,
  ]
}

### Lambda Permissions ###

resource "aws_lambda_permission" "this" {
  count = length(var.functions)

  action        = "lambda:InvokeFunction"
  function_name = var.functions[count.index].name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/${var.functions[count.index].http_method}${var.functions[count.index].path}"
}

### Custom Domain ###

resource "aws_api_gateway_domain_name" "this" {
  count = var.domain_name != null && var.domain_certificate_arn != null ? 1 : 0

  domain_name              = var.domain_name
  regional_certificate_arn = var.domain_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count = var.domain_name != null && var.domain_certificate_arn != null ? 1 : 0

  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
}

### Logs ###

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/apigateway/${var.name}"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = var.role
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    logging_level   = "INFO"
    metrics_enabled = true
  }

  depends_on = [aws_api_gateway_account.this]
}
