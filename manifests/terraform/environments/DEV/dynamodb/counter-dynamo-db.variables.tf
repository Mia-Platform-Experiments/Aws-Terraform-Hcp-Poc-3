variable "_module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-dynamodb.git?ref=v1.0.0"
}

variable "service_name" {
  description = "The name of the DynamoDB table."
  type        = string
  default     = "aws-poc-3-counter"
}

variable "performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "partition_key" {
  description = "Name of the partition key (string)."
  type        = string
  default     = "pk"
}

variable "additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
