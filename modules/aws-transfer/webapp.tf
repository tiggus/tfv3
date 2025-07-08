resource "awscc_transfer_web_app" "webapp" {
  identity_provider_details = {
    instance_arn = data.aws_ssoadmin_instances.root.arns[0]
    role         = aws_iam_role.webapp.arn

  }
  web_app_units = {
    provisioned = 1
  }
  web_app_customization = {
    title = "terraform"
  }
  tags = [
    {
      key   = "Name"
      value = "terraform"
    }
  ]
}

resource "aws_ssoadmin_application_assignment" "webapp" {
  application_arn = awscc_transfer_web_app.webapp.identity_provider_details.application_arn
  principal_id    = data.aws_identitystore_group.identitystore.group_id
  principal_type  = "GROUP"
}

resource "awscc_transfer_web_app" "webapp_account" {
  identity_provider_details = {
    instance_arn = data.aws_ssoadmin_instances.account_level.arns[0]
    role         = aws_iam_role.webapp.arn

  }
  web_app_units = {
    provisioned = 1
  }
  web_app_customization = {
    title = "sso"
  }
  tags = [
    {
      key   = "Name"
      value = "sso"
    }
  ]
}

resource "aws_ssoadmin_application_assignment" "webapp_account" {
  application_arn = awscc_transfer_web_app.webapp_account.identity_provider_details.application_arn
  principal_id    = data.aws_identitystore_group.identitystore_local.group_id
  principal_type  = "GROUP"
}