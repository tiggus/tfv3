data "aws_ssoadmin_instances" "root" {
  provider = aws.root
}

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
