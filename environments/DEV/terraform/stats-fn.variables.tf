variable "stats-fn__module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-lambda.git?ref=v1.1.0"
}

variable "stats-fn_service_name" {
  description = "The name of the Lambda function."
  type        = string
  default     = "aws-poc-3-stats"
}

variable "stats-fn_performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "stats-fn_source_code" {
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

variable "stats-fn_source_filename" {
  description = "File name of the inline code."
  type        = string
  default     = "index.mjs"
}

variable "stats-fn_deployed_service" {
  description = "Name of the microservice (in the Console) whose package runs in this function, when source_code is empty."
  type        = string
  default     = ""
}

variable "stats-fn_artifacts_bucket" {
  description = "Bucket where microservice pipelines upload their packages."
  type        = string
  default     = "aws-demo-artifacts"
}

variable "stats-fn_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs22.x"
}

variable "stats-fn_handler" {
  description = "Function entrypoint."
  type        = string
  default     = "index.handler"
}

variable "stats-fn_environment_variables" {
  description = "Environment variables as a JSON object. Use ref:<resource>.<output> to link another resource."
  type        = string
  default     = <<-EOT
{"TABLE_NAME": "ref:counter-dynamo-db.table_name"}
EOT
}

variable "stats-fn_dynamodb_table_arn" {
  description = "DynamoDB table the function can read and write (optional), e.g. ref:counter.table_arn"
  type        = string
  default     = "ref:counter-dynamo-db.table_arn"
}

variable "stats-fn_additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
