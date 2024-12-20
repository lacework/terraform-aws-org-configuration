terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.55.0"
    }
    lacework = {
      source  = "lacework/lacework"
      version = "~> 2.0"
    }
  }
}
