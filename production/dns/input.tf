variable "delegation_set" {
    description = "The pre-created DNS server delegation set."
    default     = "N3PQX76GIB3TOA"
}

variable "domain" {
    description = "The name of the domain to build."
    default     = "worstpaladin.eu"
}

variable "aws_region" {
    description = "The AWS region to create the infrastructure in."
    default     = "eu-west-2"
}
