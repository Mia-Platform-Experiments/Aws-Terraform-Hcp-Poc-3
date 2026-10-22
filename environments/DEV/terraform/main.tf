terraform {
  cloud {
    organization = "mia-platform"
    workspaces {
      name = "mia-aws-terraform-hcp-poc-3-main-dev"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

module "cognito-auth" {
  source = "git::https://github.com/dlafficare/tf-aws-cognito.git?ref=v1.0.0"

  service_name = var.cognito-auth_service_name
  performance_profile = var.cognito-auth_performance_profile
  demo_username = var.cognito-auth_demo_username
  demo_password = var.cognito-auth_demo_password
  additional_tags = {}
}

output "cognito-auth" {
  value = module.cognito-auth
}

module "counter-dynamo-db" {
  source = "git::https://github.com/dlafficare/tf-aws-dynamodb.git?ref=v1.0.0"

  service_name = var.counter-dynamo-db_service_name
  performance_profile = var.counter-dynamo-db_performance_profile
  partition_key = var.counter-dynamo-db_partition_key
  additional_tags = {}
}

output "counter-dynamo-db" {
  value = module.counter-dynamo-db
}

module "api" {
  source = "git::https://github.com/dlafficare/tf-aws-http-api.git?ref=v1.0.0"

  service_name = var.api_service_name
  performance_profile = var.api_performance_profile
  routes = {"POST /sum":module.sum-fn.invoke_arn,"GET /stats":module.stats-fn.invoke_arn}
  authorization = var.api_authorization
  jwt_issuer = module.cognito-auth.issuer_url
  jwt_audience = module.cognito-auth.client_id
  cors_allowed_origins = var.api_cors_allowed_origins
  additional_tags = {}
}

output "api" {
  value = module.api
}

module "stats-fn" {
  source = "git::https://github.com/dlafficare/tf-aws-lambda.git?ref=v1.1.0"

  service_name = var.stats-fn_service_name
  performance_profile = var.stats-fn_performance_profile
  source_code = var.stats-fn_source_code
  source_filename = var.stats-fn_source_filename
  deployed_service = var.stats-fn_deployed_service
  artifacts_bucket = var.stats-fn_artifacts_bucket
  runtime = var.stats-fn_runtime
  handler = var.stats-fn_handler
  environment_variables = {"TABLE_NAME":module.counter-dynamo-db.table_name}
  dynamodb_table_arn = module.counter-dynamo-db.table_arn
  additional_tags = {}
}

output "stats-fn" {
  value = module.stats-fn
}

module "sum-fn" {
  source = "git::https://github.com/dlafficare/tf-aws-lambda.git?ref=v1.1.0"

  service_name = var.sum-fn_service_name
  performance_profile = var.sum-fn_performance_profile
  source_code = var.sum-fn_source_code
  source_filename = var.sum-fn_source_filename
  deployed_service = var.sum-fn_deployed_service
  artifacts_bucket = var.sum-fn_artifacts_bucket
  runtime = var.sum-fn_runtime
  handler = var.sum-fn_handler
  environment_variables = {"TABLE_NAME":module.counter-dynamo-db.table_name}
  dynamodb_table_arn = module.counter-dynamo-db.table_arn
  additional_tags = {}
}

output "sum-fn" {
  value = module.sum-fn
}

module "web" {
  source = "git::https://github.com/dlafficare/tf-aws-spa.git?ref=v1.1.0"

  service_name = var.web_service_name
  performance_profile = var.web_performance_profile
  index_html = var.web_index_html
  deployed_service = var.web_deployed_service
  artifacts_bucket = var.web_artifacts_bucket
  runtime_config = {"apiUrl":module.api.api_url,"userPoolId":module.cognito-auth.user_pool_id,"clientId":module.cognito-auth.client_id,"region":module.cognito-auth.region}
  additional_tags = {}
}

output "web" {
  value = module.web
}
