output "cluster_name" {
  description = "eks cluster name"
  value       = local.cluster_name
}

output "availability_zones" {
  description = "aws availability sones"
  value       = data.aws_availability_zones.available.names
}

# output "private_subnets" {
#   value = 
# }


# output "cluster_endpoint" {
#   description = "control plane endpoint"
#   value       = module.eks.cluster_endpoint
# }

# output "cluster_security_group_id" {
#   description = "control plane security group"
#   value       = module.eks.cluster_security_group_id
# }

# output "cluster_name" {
#   description = "eks cluster name"
#   value       = module.eks.cluster_name
# }



# output "availability_zones" {
#   description = "aws availability sones"
#   value       = local.availability_zones.names
# }
