variable "api__module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-http-api.git?ref=v1.0.0"
}

variable "api_service_name" {
  description = "The name of the API."
  type        = string
  default     = "aws-poc-3-api"
}

variable "api_performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "api_routes" {
  description = "Routes as a JSON object: \"METHOD /path\" -> invoke ARN of a Lambda function."
  type        = string
  default     = <<-EOT
{"POST /sum": "ref:sum-fn.invoke_arn", "GET /stats": "ref:stats-fn.invoke_arn"}
EOT
}

variable "api_authorization" {
  description = "none: public routes. jwt: every route requires a valid JWT."
  type        = string
  default     = "jwt"
}

variable "api_jwt_issuer" {
  description = "JWT issuer when authorization is jwt, e.g. ref:auth.issuer_url"
  type        = string
  default     = "ref:cognito-auth.issuer_url"
}

variable "api_jwt_audience" {
  description = "JWT audience, e.g. ref:auth.client_id"
  type        = string
  default     = "ref:cognito-auth.client_id"
}

variable "api_cors_allowed_origins" {
  description = "Comma-separated origins allowed from browsers."
  type        = string
  default     = "*"
}

variable "api_additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
