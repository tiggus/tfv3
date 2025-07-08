# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }

# output "caller_arn" {
#   value = data.aws_caller_identity.current.arn
# }

# output "private_subnet_ids" {
#   value = module.aws-vpc.private_subnet_ids
# }

# output "dns" {
#   value = data.aws_route53_zone.domain
# }

# output "certificate" {
#   value     = aws_acm_certificate.network
#   sensitive = true
# }

# output "random" {
#   value = random_id.random
# }

output "webapp_local_url" {
  value = module.aws-transfer.webapp_local_url
}

output "webapp_sso_url" {
  value = module.aws-transfer.webapp_sso_url
}

output "root_sso" {
  value = module.aws-transfer.root_sso
}

output "account_level_sso" {
  value = module.aws-transfer.account_sso
}