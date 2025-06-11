# terraform {

#   required_version = "~> 1.10"

#   required_providers {
#     # aws = {
#     #   source  = "hashicorp/aws"
#     #   version = "~> 5.78.0"
#     # }

#     random = {
#       source  = "hashicorp/random"
#       version = "~> 3.6.1"
#     }
#   }
# }

# provider "aws" {
#   default_tags {
#     tags = {
#       environment = "sandbox"
#       builder     = "terraform"
#     }
#   }
# }


# provider "aws" {
#   region = "eu-west-1"
#   alias  = "eu-west-1"
# }

# provider "aws" {
#   region = "eu-west-2"
#   alias  = "eu-west-2"
# }

# provider "aws" {
#   region = "eu-west-2"
#   alias  = "euw2-no-tags"
# }

provider "aws" {
  #region                      = "${var.region}"
  region                      = "eu-west-2"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"

  endpoints {
    dynamodb = "http://localhost:4569"
    s3       = "http://localhost:4572"
  }

}