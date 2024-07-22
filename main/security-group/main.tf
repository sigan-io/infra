locals {
  name_tag = title(replace(var.name, "-", " "))
}

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description

  vpc_id = var.vpc_id

  tags = {
    Name = local.name_tag
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  count = length(var.ingress_rules)

  description                  = var.ingress_rules[count.index].description
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.ingress_rules[count.index].referenced_security_group
  cidr_ipv4                    = var.ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.ingress_rules[count.index].cidr_ipv6
  from_port                    = coalesce(var.ingress_rules[count.index].from_port, var.ingress_rules[count.index].port)
  to_port                      = coalesce(var.ingress_rules[count.index].to_port, var.ingress_rules[count.index].port)
  ip_protocol                  = var.ingress_rules[count.index].ip_protocol

  tags = {
    Name = local.name_tag
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = length(var.egress_rules)

  description                  = var.egress_rules[count.index].description
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.egress_rules[count.index].referenced_security_group
  cidr_ipv4                    = var.egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.egress_rules[count.index].cidr_ipv6
  from_port                    = coalesce(var.egress_rules[count.index].from_port, var.egress_rules[count.index].port)
  to_port                      = coalesce(var.egress_rules[count.index].to_port, var.egress_rules[count.index].port)
  ip_protocol                  = var.egress_rules[count.index].ip_protocol

  tags = {
    Name = local.name_tag
  }
}
