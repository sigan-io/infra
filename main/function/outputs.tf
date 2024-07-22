output "function_name" {
  description = "The name of the function."
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "The ARN of the function."
  value       = aws_lambda_function.this.invoke_arn
}
