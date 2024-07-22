output "sigan_io" {
  description = "A map containing the sigan.io domain name and zone ID."
  value = {
    domain_name = aws_route53_zone.sigan_io.name
    zone_id     = aws_route53_zone.sigan_io.zone_id
  }
}

output "sigan_site" {
  description = "A map containing the sigan.site domain name and zone ID."
  value = {
    domain_name = aws_route53_zone.sigan_site.name
    zone_id     = aws_route53_zone.sigan_site.zone_id
  }
}

output "certificates" {
  value = {
    wildcard_sigan_io   = module.wildcard_sigan_io_certificate.certificate_arn
    wildcard_sigan_site = module.wildcard_sigan_site_certificate.certificate_arn
  }
}
