module "aws-vpc" {
  create_vpc             = true
  create_public_subnets  = true
  create_private_subnets = true
  create_igw             = true
  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  enable_dns_support     = true
  ip_cidr_range          = var.ip_cidr_range
  ip_private_subnets     = var.ip_private_subnets
  ip_public_subnets      = var.ip_public_subnets
  manage_security_group  = true
  manage_nacl            = true
  manage_route_table     = true
  providers = {
    aws = aws.eu-west-2
  }
  source             = "./modules/aws-vpc"
  single_nat_gateway = true
}

# module "aws-vpc-euw1" {
#   create_vpc             = true
#   create_public_subnets  = true
#   create_private_subnets = true
#   create_igw             = true
#   enable_dns_hostnames   = true
#   enable_nat_gateway     = true
#   enable_dns_support     = true
#   ip_cidr_range          = var.ip_cidr_range_euw1
#   ip_private_subnets     = var.ip_private_subnets_euw1
#   ip_public_subnets      = var.ip_public_subnets_euw1
#   manage_security_group  = true
#   manage_nacl            = true
#   manage_route_table     = true
#   providers = {
#     aws = aws.eu-west-1
#   }
#   source             = "./modules/aws-vpc"
#   single_nat_gateway = true
# }
