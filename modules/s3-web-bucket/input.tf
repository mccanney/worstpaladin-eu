variable "bucket_name" {
  type        = string
  description = "The name of the bucket to create"
}

variable "index_file" {
  type        = string
  description = "The filename of the web bucket index document"
  default     = "index.html"
}

variable "error_file" {
  type        = string
  description = "The filename of the web bucket 404 document"
  default     = "error.html"
}

variable "environment" {
  type        = string
  description = "The name of the current environment"
  default     = "Development"
}
