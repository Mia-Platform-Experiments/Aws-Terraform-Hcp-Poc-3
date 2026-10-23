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
