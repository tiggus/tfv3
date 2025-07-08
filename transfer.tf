module "aws-transfer" {
  #account_id          = data.aws_caller_identity.current.account_id
  #   authentication_mode = var.eks_auth_mode
  #   cluster_root        = var.eks_root
  #   create_cluster      = true
  #   cluster_version     = var.eks_version
  #   providers = {
  #     aws = aws.eu-west-2
  #   }
  source = "./modules/aws-transfer"
  #   private_subnet_ids     = module.aws-vpc.private_subnet_ids
  #   cluster_upgrade_policy = var.eks_upgrade_policy
}




# resource "aws_transfer_server" "transfer" {
#   identity_provider_type = "SERVICE_MANAGED"
#   tags = {
#     Name = "transfer${random_id.random.hex}"
#   }
# }

# data "aws_iam_policy_document" "service" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["transfer.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "transfer" {
#   name               = "transfer${random_id.random.hex}"
#   assume_role_policy = data.aws_iam_policy_document.service.json
# }

# data "aws_iam_policy_document" "transfer" {
#   statement {
#     sid       = "AllowFullAccesstoS3"
#     effect    = "Allow"
#     actions   = ["s3:*"]
#     resources = [aws_s3_bucket.sftp.arn]
#   }
# }

# resource "aws_iam_role_policy" "transfer" {
#   name   = "transfer${random_id.random.hex}"
#   role   = aws_iam_role.transfer.id
#   policy = data.aws_iam_policy_document.transfer.json
# }

# resource "aws_transfer_user" "transfer" {
#   server_id = aws_transfer_server.transfer.id
#   user_name = "tf${random_id.random.hex}"
#   role      = aws_iam_role.transfer.arn

#   home_directory_type = "PATH"
#   home_directory      = "/${aws_s3_bucket.sftp.id}"
#   #   home_directory_mappings {
#   #     entry  = "/"
#   #     target = "/${aws_s3_bucket.sftp.id}"
#   #   }
# }

# resource "aws_s3_bucket" "sftp" {
#   bucket = "sftp${random_id.random.hex}"

#   tags = {
#     Name = "sftp${random_id.random.hex}"
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = "aws s3 rm s3://${self.bucket} --recursive"
#   }
# }

# resource "tls_private_key" "transfer" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }



# resource "aws_key_pair" "generated_key" {
#   key_name   = "key${random_id.random.hex}"
#   public_key = tls_private_key.transfer.public_key_openssh
# }

# resource "aws_transfer_ssh_key" "transfer" {
#   server_id = aws_transfer_server.transfer.id
#   user_name = aws_transfer_user.transfer.user_name
#   body      = trimspace(tls_private_key.transfer.public_key_openssh)
# }

# output "private_key" {
#   value     = tls_private_key.transfer.private_key_pem
#   sensitive = true
# }

# resource "aws_transfer_user" "user1" {
#   server_id = aws_transfer_server.transfer.id
#   user_name = "user1${random_id.random.hex}"
#   role      = aws_iam_role.transfer-users.arn

#   home_directory_type = "PATH"
#   home_directory      = "/${aws_s3_bucket.sftp.id}/folder1"
#   #   home_directory_mappings {
#   #     entry  = "/"
#   #     target = "/${aws_s3_bucket.sftp.id}"
#   #   }
# }

# resource "aws_transfer_user" "user2" {
#   server_id = aws_transfer_server.transfer.id
#   user_name = "user2${random_id.random.hex}"
#   role      = aws_iam_role.transfer-users.arn

#   home_directory_type = "PATH"
#   home_directory      = "/${aws_s3_bucket.sftp.id}/folder2"
#   #   home_directory_mappings {
#   #     entry  = "/"
#   #     target = "/${aws_s3_bucket.sftp.id}"
#   #   }
# }

# data "aws_iam_policy_document" "transfer-users" {
#   statement {
#     effect    = "Allow"
#     actions   = ["s3:Read"]
#     resources = [aws_s3_bucket.sftp.arn]
#   }
# }

# resource "aws_iam_role_policy" "transfer-users" {
#   name   = "transfer-users${random_id.random.hex}"
#   role   = aws_iam_role.transfer-users.id
#   policy = data.aws_iam_policy_document.transfer-users.json
# }

# resource "aws_iam_role" "transfer-users" {
#   name               = "transfer-users${random_id.random.hex}"
#   assume_role_policy = data.aws_iam_policy_document.service.json
# }
