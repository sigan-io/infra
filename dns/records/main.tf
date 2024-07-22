### Create Domain Records ###

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = var.domain_zone_id
  name    = each.value.name
  type    = each.value.type
  records = each.value.records
  ttl     = each.value.records != null ? 60 : null

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health != null ? alias.value.evaluate_target_health : false
    }
  }
}
