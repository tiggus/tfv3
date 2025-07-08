# module "aws-vpc" {
#   create_vpc             = true
#   create_public_subnets  = true
#   create_private_subnets = true
#   create_igw             = true
#   enable_dns_hostnames   = true
#   enable_nat_gateway     = true
#   enable_dns_support     = true
#   ip_cidr_range          = var.ip_cidr_range
#   ip_private_subnets     = var.ip_private_subnets
#   ip_public_subnets      = var.ip_public_subnets
#   manage_security_group  = true
#   manage_nacl            = true
#   manage_route_table     = true
#   providers = {
#     aws = aws.eu-west-2
#   }
#   source             = "./modules/aws-vpc"
#   single_nat_gateway = true
# }

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id          = module.aws-vpc.vpc_id
#   service_name    = "com.amazonaws.eu-west-2.s3"
#   route_table_ids = [module.aws-vpc.private_route, module.aws-vpc.public_route]
#   policy          = data.aws_iam_policy_document.s3.json
#   tags = {
#     Name = "endpoint-s3"
#   }
# }

# data "aws_iam_policy_document" "s3" {
#   statement {
#     actions   = ["s3:*"]
#     resources = ["*"]
#     effect    = "Allow"
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }
#   }
# }
