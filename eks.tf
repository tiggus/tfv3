module "aws-eks" {
  account_id          = data.aws_caller_identity.current.account_id
  authentication_mode = var.eks_auth_mode
  cluster_root        = var.eks_root
  create_cluster      = true
  cluster_version     = var.eks_version
  providers = {
    aws = aws.eu-west-2
  }
  source                 = "./modules/aws-eks"
  private_subnet_ids     = module.aws-vpc.private_subnet_ids
  cluster_upgrade_policy = var.eks_upgrade_policy
}

resource "aws_eks_node_group" "node-group" {
  cluster_name           = module.aws-eks.cluster_name
  node_group_name_prefix = "nodegroup-"
  node_role_arn          = aws_iam_role.node-group.arn
  subnet_ids             = module.aws-vpc.private_subnet_ids
  version                = var.eks_version
  instance_types         = ["t3.nano"]
  ami_type               = "BOTTLEROCKET_x86_64"
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.node-group,
    module.aws-eks
  ]
}

resource "aws_eks_access_entry" "node-group" {
  cluster_name  = module.aws-eks.cluster_name
  principal_arn = "arn:aws:iam::656701891001:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_AWSAdministratorAccess_10f0e24f9e960885"
  type          = "STANDARD"
  depends_on    = [module.aws-eks]
}

resource "aws_eks_access_policy_association" "node-group" {
  cluster_name  = module.aws-eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.node-group.principal_arn

  access_scope {
    type = "cluster"
  }
}
