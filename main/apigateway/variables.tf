variable "name" {
  description = "The name of the API Gateway."
  type        = string
}

variable "description" {
  description = "The description of the API Gateway."
  type        = string
}

variable "openapi_filepath" {
  description = "The path to the OpenAPI template file."
  type        = string
}

variable "role" {
  description = "The role's ARN of the API Gateway."
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage."
  type        = string
}

variable "functions" {
  description = "The functions integrated with the API Gateway."
  type = list(object({
    name        = string
    invoke_arn  = string
    http_method = string
    path        = string
  }))

  validation {
    condition     = alltrue([for function in var.functions : contains(["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "PATCH"], function.http_method)])
    error_message = "The method must be one of GET, POST, PUT, DELETE, HEAD, OPTIONS, PATCH."
  }

  validation {
    condition     = alltrue([for function in var.functions : startswith(function.path, "/")])
    error_message = "The path must start with `/`."
  }
}

variable "domain_name" {
  description = "The name of the custom domain."
  type        = string
  default     = null
}

variable "domain_certificate_arn" {
  description = "The ARN of the domain's certificate."
  type        = string
  default     = null
}
