# module "aws-eks-euw1" {
#   account_id   = data.aws_caller_identity.current.account_id
#   cluster_root = var.cluster_root
#   providers = {
#     aws = aws.eu-west-1
#   }
#   source = "./modules/aws-eks"
# }

module "aws-eks" {
  account_id          = data.aws_caller_identity.current.account_id
  authentication_mode = "API"
  cluster_root        = var.cluster_root
  create_cluster      = true
  cluster_version     = "1.33"
  providers = {
    aws = aws.eu-west-2
  }
  source             = "./modules/aws-eks"
  private_subnet_ids = module.aws-vpc.private_subnet_ids
  #  depends_on         = [module.aws-vpc]
}



# # module "aws-eks-euw2" {
# #   account_id   = data.aws_caller_identity.current.account_id
# #   cluster_root = var.cluster_root
# #   providers = {
# #     aws = aws.eu-west-2
# #   }
# #   source = "./modules/aws-eks"
# # }



# resource "aws_iam_user" "the-accounts" {
#   for_each = toset(["Todd", "James", "Alice", "Dottie"])
#   name     = each.key
# }