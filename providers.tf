terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

  }

  required_version = ">= 0.14"
}
