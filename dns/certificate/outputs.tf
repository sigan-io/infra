output "certificate_arn" {
  description = "The ARN of the certificate."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain_validation_options" {
  description = "The domain validation options of the certificate."
  value       = aws_acm_certificate.this.domain_validation_options
}
