# resource "awscc_transfer_web_app" "webapp" {
#   identity_provider_details = {
#     instance_arn = data.aws_ssoadmin_instances.root.arns[0]
#     role         = "arn:aws:iam::656701891001:role/service-role/AWSTransferWebAppIdentityBearer-eu-west-2"

#   }
#   web_app_units = {
#     provisioned = 1
#   }
#   web_app_customization = {
#     title = "terraform"
#   }
#   tags = [
#     {
#       key   = "Name"
#       value = "terraform"
#     }
#   ]
# }

# resource "aws_ssoadmin_application_assignment" "webapp" {
#   application_arn = awscc_transfer_web_app.webapp.identity_provider_details.application_arn
#   principal_id    = data.aws_identitystore_group.identitystore.group_id
#   principal_type  = "GROUP"
# }


