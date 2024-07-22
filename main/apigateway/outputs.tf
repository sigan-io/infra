output "invoke_url" {
  value = aws_api_gateway_stage.this.invoke_url
}

output "rendered_openapi" {
  value = templatefile(var.openapi_filepath, local.functions_map)
}

output "regional_domain_name" {
  value = var.domain_name != null && var.domain_certificate_arn != null ? aws_api_gateway_domain_name.this[0].regional_domain_name : null
}

output "regional_zone_id" {
  value = var.domain_name != null && var.domain_certificate_arn != null ? aws_api_gateway_domain_name.this[0].regional_zone_id : null
}
