data "aws_ssoadmin_instances" "root" {
  provider = aws.root
}

data "aws_ssoadmin_instances" "account_level" {}


data "aws_identitystore_group" "identitystore" {
  provider          = aws.root
  identity_store_id = tolist(data.aws_ssoadmin_instances.root.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.identity_store_group
    }
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


data "aws_identitystore_group" "identitystore_local" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.account_level.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.identity_store_group_local
    }
  }
}

