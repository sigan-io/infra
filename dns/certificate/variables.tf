variable "domain_name" {
  description = "The name of the domain."
  type        = string
}

variable "alternative_domain_names" {
  description = "The name of the subdomains."
  type        = list(string)
  default     = []
}

variable "domain_zone_id" {
  description = "The Route 53 zone id of the domain."
  type        = string
}
