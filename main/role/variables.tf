variable "name" {
  description = "The name of the role."
  type        = string
}

variable "description" {
  description = "The description of the role."
  type        = string
}

variable "service" {
  description = "The service to assume the role."
  type        = string
}

variable "managed_policies" {
  description = "List of policies to attach to the role."
  type        = list(string)
  default     = []
}
