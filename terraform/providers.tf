terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
  backend "s3" {
    bucket       = "nimbusops-tfstate-first-01"
    key          = "nimbusops/dev/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}
