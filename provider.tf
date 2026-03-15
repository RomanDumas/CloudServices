terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "328944069584-terraform-tfstate"
    key            = "lab1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}