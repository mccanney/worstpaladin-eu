variable "bucket_name" {
  type        = string
  description = "The name of the bucket to create"
}

variable "environment" {
  type        = string
  description = "The name of the current environment"
  default     = "Development"
}
