terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }
  #State Lock with DybamoDB Table is deprecated, use use_lockfile = true instead. See https://developer.hashicorp.com/terraform/language/settings/backends/s3#state-locking for more information.
  backend "s3" {
    bucket         = "fdivine-recipe-app-tf-state"
    key            = "daily-task-planner/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "fdivine-recipe-api-tf-lock"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project = var.project
      Contact = var.contact
    }
  }
}
