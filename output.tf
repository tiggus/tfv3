output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

# output "cluster_euw1" {
#   value = module.aws-eks-euw1.cluster_name
# }

# output "cluster_euw2" {
#   value = module.aws-eks-euw2.cluster_name
# }

# output "aws_availability_zones_euw1" {
#   value = module.aws-eks-euw1.availability_zones
# }

# output "aws_availability_zones_euw2" {
#   value = module.aws-eks-euw2.availability_zones
# }

# output "cluster" {
#   value = module.aws-eks-euw2.cluster_name
# }

# output "aws_availability_zones" {
#   value = module.aws-vpc.availability_zones
# }



output "private_subnet_ids" {
  value = module.aws-vpc.private_subnet_ids
}