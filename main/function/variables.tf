variable "name" {
  description = "The name of the function."
  type        = string
}

variable "description" {
  description = "The description of the function."
  type        = string
}

variable "handler" {
  description = "The handler of the function."
  type        = string
  default     = "bootstrap"
}

variable "bucket_name" {
  description = "The name of the bucket where the function's code is stored."
  type        = string
}

variable "runtime" {
  description = "The runtime of the function."
  type        = string
  default     = "provided.al2023"
}

variable "architectures" {
  description = "The architectures of the function."
  type        = list(string)
  default     = ["arm64"]
}

variable "timeout" {
  description = "The timeout of the function."
  type        = number
  default     = 60
}

variable "role" {
  description = "The role ARN of the function."
  type        = string
}

variable "env_variables" {
  description = "The environment variables of the function."
  type        = map(string)
  default     = {}
}
