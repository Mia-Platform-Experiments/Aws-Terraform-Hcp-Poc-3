variable "counter-dynamo-db__module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-dynamodb.git?ref=v1.0.0"
}

variable "counter-dynamo-db_service_name" {
  description = "The name of the DynamoDB table."
  type        = string
  default     = "aws-poc-3-counter"
}

variable "counter-dynamo-db_performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "counter-dynamo-db_partition_key" {
  description = "Name of the partition key (string)."
  type        = string
  default     = "pk"
}

variable "counter-dynamo-db_additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
