terraform {

  required_version = "~> 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      environment = "sandbox"
      builder     = "terraform"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

provider "aws" {
  region = "eu-west-2"
  alias  = "eu-west-2"
}

provider "aws" {
  region = "eu-west-2"
  alias  = "euw2-no-tags"
}
