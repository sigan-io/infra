variable "domain_zone_id" {
  description = "The domain's Route 53 zone id."
  type        = string
}

variable "records" {
  description = "The domain's DNS records."
  type = map(object({
    name    = string
    type    = string
    records = optional(list(string))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool)
    }))
  }))

  validation {
    condition = alltrue([
      for record in var.records :
      (record.records != null && record.alias == null) ||
      (record.records == null && record.alias != null)
    ])
    error_message = "Only `records` or `alias` must be set."
  }
}
