variable "_module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-cognito.git?ref=v1.0.0"
}

variable "service_name" {
  description = "The name of the User Pool."
  type        = string
  default     = "aws-poc-3-auth"
}

variable "performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "demo_username" {
  description = "Email of a demo user to create (optional)."
  type        = string
  default     = "demo@example.com"
}

variable "demo_password" {
  description = "Password of the demo user: min 8 chars with upper, lower, number and symbol."
  type        = string
  default     = "Demo-Aws-Poc-2026!"
}

variable "additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
