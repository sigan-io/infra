variable "name" {
  description = "The name of the bucket."
  type        = string

  validation {
    condition     = startswith(var.name, "sigan-")
    error_message = "The bucket name must start with `sigan-` to avoid conflicts with existing buckets."
  }
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket."
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Whether to enable versioning in the bucket."
  type        = bool
  default     = false
}
