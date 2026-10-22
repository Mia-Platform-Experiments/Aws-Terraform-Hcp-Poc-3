variable "_module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-lambda.git?ref=v1.1.0"
}

variable "service_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "aws-poc-3-stats"
}

variable "performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "source_code" {
  description = "Inline source code (single file). Leave empty to deploy the package of a microservice instead. Do not use the character sequence dollar + open brace."
  type        = string
  default     = <<-EOT
import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

const db = new DynamoDBClient({});

export const handler = async () => {
  const out = await db.send(new GetItemCommand({
    TableName: process.env.TABLE_NAME,
    Key: { pk: { S: "sum-count" } },
  }));
  const calls = out.Item ? Number(out.Item.calls.N) : 0;

  return {
    statusCode: 200,
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ calls }),
  };
};

EOT
}

variable "source_filename" {
  description = "File name of the inline code."
  type        = string
  default     = "index.mjs"
}

variable "deployed_service" {
  description = "Name of the microservice (in the Console) whose package runs in this function, when source_code is empty."
  type        = string
  default     = ""
}

variable "artifacts_bucket" {
  description = "Bucket where microservice pipelines upload their packages."
  type        = string
  default     = "aws-demo-artifacts"
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs22.x"
}

variable "handler" {
  description = "Function entrypoint."
  type        = string
  default     = "index.handler"
}

variable "environment_variables" {
  description = "Environment variables as a JSON object. Use ref:<resource>.<output> to link another resource."
  type        = string
  default     = <<-EOT
{"TABLE_NAME": "ref:counter-dynamo-db.table_name"}
EOT
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table the function can read and write (optional), e.g. ref:counter.table_arn"
  type        = string
  default     = "ref:counter-dynamo-db.table_arn"
}

variable "additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
