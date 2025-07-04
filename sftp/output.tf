output "sso_instance_arn" {
  value = data.aws_ssoadmin_instances.root.arns[0]
}

output "group_id" {
  value = data.aws_identitystore_group.identitystore.group_id
}

output "private_key" {
  value     = tls_private_key.transfer.private_key_pem
  sensitive = true
}

output "webapp" {
  value = awscc_transfer_web_app.webapp.access_endpoint
}
