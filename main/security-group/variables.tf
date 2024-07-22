variable "name" {
  description = "The name of the security group."
  type        = string
}

variable "description" {
  description = "The description of the security group."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which to create the security group."
  type        = string
}

variable "ingress_rules" {
  description = "The list of ingress rules."
  type = list(object({
    description               = optional(string)
    referenced_security_group = optional(string)
    cidr_ipv4                 = optional(string)
    cidr_ipv6                 = optional(string)
    port                      = optional(number)
    from_port                 = optional(number)
    to_port                   = optional(number)
    ip_protocol               = optional(string, "tcp")
  }))

  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      ((rule.port != null && rule.from_port == null && rule.to_port == null) ||
      (rule.port == null && rule.from_port != null && rule.to_port != null))
    ])
    error_message = "Either `port` or (`from_port` and `to_port`) must be set."
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules :
      length(compact([
        rule.referenced_security_group != null ? "1" : "",
        rule.cidr_ipv4 != null ? "1" : "",
        rule.cidr_ipv6 != null ? "1" : "",
      ])) == 1
    ])
    error_message = "Either `referenced_security_group`, `cidr_ipv4` or `cidr_ipv6` must be set."
  }
}

variable "egress_rules" {
  description = "The list of egress rules."
  type = list(object({
    description               = optional(string)
    referenced_security_group = optional(string)
    cidr_ipv4                 = optional(string)
    cidr_ipv6                 = optional(string)
    port                      = optional(number)
    from_port                 = optional(number)
    to_port                   = optional(number)
    ip_protocol               = optional(string, "tcp")
  }))

  default = []

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      ((rule.port != null && rule.from_port == null && rule.to_port == null) ||
      (rule.port == null && rule.from_port != null && rule.to_port != null))
    ])
    error_message = "Either `port` or (`from_port` and `to_port`) must be set."
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules :
      length(compact([
        rule.referenced_security_group != null ? "1" : "",
        rule.cidr_ipv4 != null ? "1" : "",
        rule.cidr_ipv6 != null ? "1" : "",
      ])) == 1
    ])
    error_message = "Either `referenced_security_group`, `cidr_ipv4` or `cidr_ipv6` must be set."
  }
}
