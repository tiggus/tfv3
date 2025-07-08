# resource "aws_iam_role" "node-group" {
#   name = "eks-node-group"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "node-group" {
#   for_each   = toset(["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"])
#   policy_arn = each.key
#   role       = aws_iam_role.node-group.name
# }

# resource "aws_iam_account_alias" "alias" {
#   account_alias = "${var.account_name}-${var.account_env}${random_id.random.hex}"
#   lifecycle {
#     ignore_changes = all
#   }
# }
