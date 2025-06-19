resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_eks_cluster" "cluster" {
  count = var.create_cluster ? 1 : 0
  name = local.cluster_name

  access_config {
    authentication_mode = var.authentication_mode
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
  }

  #ip_private_subnets     = var.ip_private_subnets
  #ip_public_subnets      = var.ip_public_subnets


  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  name = "eks-${local.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# resource "aws_eks_cluster" "cluster" {
#   count = var.create_cluster ? 1 : 0

#   name                          = var.cluster_name
#   role_arn                      = local.cluster_role
#   version                       = var.cluster_version
#   enabled_cluster_log_types     = var.cluster_enabled_log_types
#   bootstrap_self_managed_addons = local.auto_mode_enabled ? coalesce(var.bootstrap_self_managed_addons, false) : var.bootstrap_self_managed_addons
#   force_update_version          = var.cluster_force_update_version

#   access_config {
#     authentication_mode = var.authentication_mode

#     # See access entries below - this is a one time operation from the EKS API.
#     # Instead, we are hardcoding this to false and if users wish to achieve this
#     # same functionality, we will do that through an access entry which can be
#     # enabled or disabled at any time of their choosing using the variable
#     # var.enable_cluster_creator_admin_permissions
#     bootstrap_cluster_creator_admin_permissions = false
#   }

#   dynamic "compute_config" {
#     for_each = length(var.cluster_compute_config) > 0 ? [var.cluster_compute_config] : []

#     content {
#       enabled       = local.auto_mode_enabled
#       node_pools    = local.auto_mode_enabled ? try(compute_config.value.node_pools, []) : null
#       node_role_arn = local.auto_mode_enabled && length(try(compute_config.value.node_pools, [])) > 0 ? try(compute_config.value.node_role_arn, aws_iam_role.eks_auto[0].arn, null) : null
#     }
#   }

#   vpc_config {
#     security_group_ids      = compact(distinct(concat(var.cluster_additional_security_group_ids, [local.cluster_security_group_id])))
#     subnet_ids              = coalescelist(var.control_plane_subnet_ids, var.subnet_ids)
#     endpoint_private_access = var.cluster_endpoint_private_access
#     endpoint_public_access  = var.cluster_endpoint_public_access
#     public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
#   }

#   dynamic "kubernetes_network_config" {
#     # Not valid on Outposts
#     for_each = local.create_outposts_local_cluster ? [] : [1]

#     content {
#       dynamic "elastic_load_balancing" {
#         for_each = local.auto_mode_enabled ? [1] : []

#         content {
#           enabled = local.auto_mode_enabled
#         }
#       }

#       ip_family         = var.cluster_ip_family
#       service_ipv4_cidr = var.cluster_service_ipv4_cidr
#       service_ipv6_cidr = var.cluster_service_ipv6_cidr
#     }
#   }

#   dynamic "outpost_config" {
#     for_each = local.create_outposts_local_cluster ? [var.outpost_config] : []

#     content {
#       control_plane_instance_type = outpost_config.value.control_plane_instance_type
#       outpost_arns                = outpost_config.value.outpost_arns
#     }
#   }

#   dynamic "encryption_config" {
#     # Not available on Outposts
#     for_each = local.enable_cluster_encryption_config ? [var.cluster_encryption_config] : []

#     content {
#       provider {
#         key_arn = var.create_kms_key ? module.kms.key_arn : encryption_config.value.provider_key_arn
#       }
#       resources = encryption_config.value.resources
#     }
#   }

#   dynamic "remote_network_config" {
#     # Not valid on Outposts
#     for_each = length(var.cluster_remote_network_config) > 0 && !local.create_outposts_local_cluster ? [var.cluster_remote_network_config] : []

#     content {
#       dynamic "remote_node_networks" {
#         for_each = [remote_network_config.value.remote_node_networks]

#         content {
#           cidrs = remote_node_networks.value.cidrs
#         }
#       }

#       dynamic "remote_pod_networks" {
#         for_each = try([remote_network_config.value.remote_pod_networks], [])

#         content {
#           cidrs = remote_pod_networks.value.cidrs
#         }
#       }
#     }
#   }

#   dynamic "storage_config" {
#     for_each = local.auto_mode_enabled ? [1] : []

#     content {
#       block_storage {
#         enabled = local.auto_mode_enabled
#       }
#     }
#   }

#   dynamic "upgrade_policy" {
#     for_each = length(var.cluster_upgrade_policy) > 0 ? [var.cluster_upgrade_policy] : []

#     content {
#       support_type = try(upgrade_policy.value.support_type, null)
#     }
#   }

#   dynamic "zonal_shift_config" {
#     for_each = length(var.cluster_zonal_shift_config) > 0 ? [var.cluster_zonal_shift_config] : []

#     content {
#       enabled = try(zonal_shift_config.value.enabled, null)
#     }
#   }

#   tags = merge(
#     { terraform-aws-modules = "eks" },
#     var.tags,
#     var.cluster_tags,
#   )

#   timeouts {
#     create = try(var.cluster_timeouts.create, null)
#     update = try(var.cluster_timeouts.update, null)
#     delete = try(var.cluster_timeouts.delete, null)
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.this,
#     aws_security_group_rule.cluster,
#     aws_security_group_rule.node,
#     aws_cloudwatch_log_group.this,
#     aws_iam_policy.cni_ipv6_policy,
#   ]

#   lifecycle {
#     ignore_changes = [
#       access_config[0].bootstrap_cluster_creator_admin_permissions
#     ]
#   }
# }

#   # module.aws-eks.module.eks.aws_eks_cluster.this[0] will be created
#   + resource "aws_eks_cluster" "this" {
#       + arn                           = (known after apply)
#       + bootstrap_self_managed_addons = true
#       + certificate_authority         = (known after apply)
#       + cluster_id                    = (known after apply)
#       + created_at                    = (known after apply)
#       + enabled_cluster_log_types     = [
#           + "api",
#           + "audit",
#           + "authenticator",
#         ]
#       + endpoint                      = (known after apply)
#       + id                            = (known after apply)
#       + identity                      = (known after apply)
#       + name                          = (known after apply)
#       + platform_version              = (known after apply)
#       + role_arn                      = (known after apply)
#       + status                        = (known after apply)
#       + tags                          = {
#           + "terraform-aws-modules" = "eks"
#         }
#       + tags_all                      = {
#           + "builder"               = "terraform"
#           + "environment"           = "sandbox"
#           + "terraform-aws-modules" = "eks"
#         }
#       + version                       = "1.29"

#       + access_config {
#           + authentication_mode                         = "API_AND_CONFIG_MAP"
#           + bootstrap_cluster_creator_admin_permissions = false
#         }

#       + encryption_config {
#           + resources = [
#               + "secrets",
#             ]

#           + provider {
#               + key_arn = (known after apply)
#             }
#         }

#       + kubernetes_network_config {
#           + ip_family         = "ipv4"
#           + service_ipv4_cidr = (known after apply)
#           + service_ipv6_cidr = (known after apply)

#           + elastic_load_balancing (known after apply)
#         }

#       + timeouts {}

#       + upgrade_policy (known after apply)

#       + vpc_config {
#           + cluster_security_group_id = (known after apply)
#           + endpoint_private_access   = true
#           + endpoint_public_access    = true
#           + public_access_cidrs       = [
#               + "0.0.0.0/0",
#             ]
#           + security_group_ids        = (known after apply)
#           + subnet_ids                = (known after apply)
#           + vpc_id                    = (known after apply)
#         }
#     }





#   # module.aws-eks.module.eks.aws_eks_cluster.this[0] will be created
#   + resource "aws_eks_cluster" "this" {
#       + arn                           = (known after apply)
#       + bootstrap_self_managed_addons = true
#       + certificate_authority         = (known after apply)
#       + cluster_id                    = (known after apply)
#       + created_at                    = (known after apply)
#       + enabled_cluster_log_types     = [
#           + "api",
#           + "audit",
#           + "authenticator",
#         ]
#       + endpoint                      = (known after apply)
#       + id                            = (known after apply)
#       + identity                      = (known after apply)
#       + name                          = (known after apply)
#       + platform_version              = (known after apply)
#       + role_arn                      = (known after apply)
#       + status                        = (known after apply)
#       + tags                          = {
#           + "terraform-aws-modules" = "eks"
#         }
#       + tags_all                      = {
#           + "builder"               = "terraform"
#           + "environment"           = "sandbox"
#           + "terraform-aws-modules" = "eks"
#         }
#       + version                       = "1.29"

#       + access_config {
#           + authentication_mode                         = "API_AND_CONFIG_MAP"
#           + bootstrap_cluster_creator_admin_permissions = false
#         }

#       + encryption_config {
#           + resources = [
#               + "secrets",
#             ]

#           + provider {
#               + key_arn = (known after apply)
#             }
#         }

#       + kubernetes_network_config {
#           + ip_family         = "ipv4"
#           + service_ipv4_cidr = (known after apply)
#           + service_ipv6_cidr = (known after apply)

#           + elastic_load_balancing (known after apply)
#         }

#       + timeouts {}

#       + upgrade_policy (known after apply)

#       + vpc_config {
#           + cluster_security_group_id = (known after apply)
#           + endpoint_private_access   = true
#           + endpoint_public_access    = true
#           + public_access_cidrs       = [
#               + "0.0.0.0/0",
#             ]
#           + security_group_ids        = (known after apply)
#           + subnet_ids                = (known after apply)
#           + vpc_id                    = (known after apply)
#         }
#     }


























# module "eks" {
#   source  = "../terraform-aws-eks"
#   #version = "20.8.5"
#   # providers = {

#   # }
#   cluster_name    = local.cluster_name
#   cluster_version = "1.29"

#   cluster_endpoint_public_access           = true
#   enable_cluster_creator_admin_permissions = true

#   cluster_addons = {
#     aws-ebs-csi-driver = {
#       service_account_role_arn = module.irsa-ebs-csi.this_iam_role_arn
#     }
#   }

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"

#   }

#   eks_managed_node_groups = {
#     one = {
#       name = "node-group-1"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 3
#       desired_size = 2
#     }

#     two = {
#       name = "node-group-2"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 2
#       desired_size = 1
#     }
#   }
# }


# # https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
# data "aws_iam_policy" "ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# module "irsa-ebs-csi" {
#   source  = "../terraform-aws-iam/modules/iam-assumable-role-with-oidc"
#   #version = "5.39.0"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#   provider_url                  = module.eks.oidc_provider
#   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }










# #######EKS

# module.aws-eks.module.eks.data.aws_eks_addon_version.this["aws-ebs-csi-driver"] will be read during apply
#   # (depends on a resource or a module with changes pending)
#  <= data "aws_eks_addon_version" "this" {
#       + addon_name         = "aws-ebs-csi-driver"
#       + id                 = (known after apply)
#       + kubernetes_version = "1.29"
#       + version            = (known after apply)
#     }

#   # module.aws-eks.module.eks.data.tls_certificate.this[0] will be read during apply
#   # (config refers to values not yet known)
#  <= data "tls_certificate" "this" {
#       + certificates = (known after apply)
#       + id           = (known after apply)
#       + url          = (known after apply)
#     }





#   # module.aws-eks.module.eks.aws_cloudwatch_log_group.this[0] will be created
#   + resource "aws_cloudwatch_log_group" "this" {
#       + arn               = (known after apply)
#       + id                = (known after apply)
#       + log_group_class   = (known after apply)
#       + name              = (known after apply)
#       + name_prefix       = (known after apply)
#       + retention_in_days = 90
#       + skip_destroy      = false
#       + tags              = (known after apply)
#       + tags_all          = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_eks_access_entry.this["cluster_creator"] will be created
#   + resource "aws_eks_access_entry" "this" {
#       + access_entry_arn  = (known after apply)
#       + cluster_name      = (known after apply)
#       + created_at        = (known after apply)
#       + id                = (known after apply)
#       + kubernetes_groups = (known after apply)
#       + modified_at       = (known after apply)
#       + principal_arn     = "arn:aws:iam::656701891001:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_AWSAdministratorAccess_10f0e24f9e960885"
#       + tags_all          = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + type              = "STANDARD"
#       + user_name         = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_eks_access_policy_association.this["cluster_creator_admin"] will be created
#   + resource "aws_eks_access_policy_association" "this" {
#       + associated_at = (known after apply)
#       + cluster_name  = (known after apply)
#       + id            = (known after apply)
#       + modified_at   = (known after apply)
#       + policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#       + principal_arn = "arn:aws:iam::656701891001:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_AWSAdministratorAccess_10f0e24f9e960885"

#       + access_scope {
#           + type = "cluster"
#         }
#     }

#   # module.aws-eks.module.eks.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
#   + resource "aws_eks_addon" "this" {
#       + addon_name                  = "aws-ebs-csi-driver"
#       + addon_version               = (known after apply)
#       + arn                         = (known after apply)
#       + cluster_name                = (known after apply)
#       + configuration_values        = (known after apply)
#       + created_at                  = (known after apply)
#       + id                          = (known after apply)
#       + modified_at                 = (known after apply)
#       + preserve                    = true
#       + resolve_conflicts_on_create = "OVERWRITE"
#       + resolve_conflicts_on_update = "OVERWRITE"
#       + service_account_role_arn    = (known after apply)
#       + tags_all                    = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }

#       + timeouts {}
#     }



#   # module.aws-eks.module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be created
#   + resource "aws_iam_openid_connect_provider" "oidc_provider" {
#       + arn             = (known after apply)
#       + client_id_list  = [
#           + "sts.amazonaws.com",
#         ]
#       + id              = (known after apply)
#       + tags            = (known after apply)
#       + tags_all        = (known after apply)
#       + thumbprint_list = (known after apply)
#       + url             = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_iam_policy.cluster_encryption[0] will be created
#   + resource "aws_iam_policy" "cluster_encryption" {
#       + arn              = (known after apply)
#       + attachment_count = (known after apply)
#       + description      = "Cluster encryption policy to allow cluster role to utilize CMK provided"
#       + id               = (known after apply)
#       + name             = (known after apply)
#       + name_prefix      = (known after apply)
#       + path             = "/"
#       + policy           = (known after apply)
#       + policy_id        = (known after apply)
#       + tags_all         = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#     }

#   # module.aws-eks.module.eks.aws_iam_policy.custom[0] will be created
#   + resource "aws_iam_policy" "custom" {
#       + arn              = (known after apply)
#       + attachment_count = (known after apply)
#       + id               = (known after apply)
#       + name             = (known after apply)
#       + name_prefix      = (known after apply)
#       + path             = "/"
#       + policy           = jsonencode(
#             {
#               + Statement = [
#                   + {
#                       + Action    = [
#                           + "ec2:RunInstances",
#                           + "ec2:CreateLaunchTemplate",
#                           + "ec2:CreateFleet",
#                         ]
#                       + Condition = {
#                           + StringEquals = {
#                               + "aws:RequestTag/eks:eks-cluster-name" = "${aws:PrincipalTag/eks:eks-cluster-name}"
#                             }
#                           + StringLike   = {
#                               + "aws:RequestTag/eks:kubernetes-node-class-name" = "*"
#                               + "aws:RequestTag/eks:kubernetes-node-pool-name"  = "*"
#                             }
#                         }
#                       + Effect    = "Allow"
#                       + Resource  = "*"
#                       + Sid       = "Compute"
#                     },
#                   + {
#                       + Action    = [
#                           + "ec2:CreateVolume",
#                           + "ec2:CreateSnapshot",
#                         ]
#                       + Condition = {
#                           + StringEquals = {
#                               + "aws:RequestTag/eks:eks-cluster-name" = "${aws:PrincipalTag/eks:eks-cluster-name}"
#                             }
#                         }
#                       + Effect    = "Allow"
#                       + Resource  = [
#                           + "arn:aws:ec2:*:*:volume/*",
#                           + "arn:aws:ec2:*:*:snapshot/*",
#                         ]
#                       + Sid       = "Storage"
#                     },
#                   + {
#                       + Action    = "ec2:CreateNetworkInterface"
#                       + Condition = {
#                           + StringEquals = {
#                               + "aws:RequestTag/eks:eks-cluster-name"         = "${aws:PrincipalTag/eks:eks-cluster-name}"
#                               + "aws:RequestTag/eks:kubernetes-cni-node-name" = "*"
#                             }
#                         }
#                       + Effect    = "Allow"
#                       + Resource  = "*"
#                       + Sid       = "Networking"
#                     },
#                   + {
#                       + Action    = [
#                           + "elasticloadbalancing:CreateTargetGroup",
#                           + "elasticloadbalancing:CreateRule",
#                           + "elasticloadbalancing:CreateLoadBalancer",
#                           + "elasticloadbalancing:CreateListener",
#                           + "ec2:CreateSecurityGroup",
#                         ]
#                       + Condition = {
#                           + StringEquals = {
#                               + "aws:RequestTag/eks:eks-cluster-name" = "${aws:PrincipalTag/eks:eks-cluster-name}"
#                             }
#                         }
#                       + Effect    = "Allow"
#                       + Resource  = "*"
#                       + Sid       = "LoadBalancer"
#                     },
#                   + {
#                       + Action    = "shield:CreateProtection"
#                       + Condition = {
#                           + StringEquals = {
#                               + "aws:RequestTag/eks:eks-cluster-name" = "${aws:PrincipalTag/eks:eks-cluster-name}"
#                             }
#                         }
#                       + Effect    = "Allow"
#                       + Resource  = "*"
#                       + Sid       = "ShieldProtection"
#                     },
#                   + {
#                       + Action    = "shield:TagResource"
#                       + Condition = {
#                           + StringEquals = {
#                               + "aws:RequestTag/eks:eks-cluster-name" = "${aws:PrincipalTag/eks:eks-cluster-name}"
#                             }
#                         }
#                       + Effect    = "Allow"
#                       + Resource  = "arn:aws:shield::*:protection/*"
#                       + Sid       = "ShieldTagResource"
#                     },
#                 ]
#               + Version   = "2012-10-17"
#             }
#         )
#       + policy_id        = (known after apply)
#       + tags_all         = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#     }

#   # module.aws-eks.module.eks.aws_iam_role.this[0] will be created
#   + resource "aws_iam_role" "this" {
#       + arn                   = (known after apply)
#       + assume_role_policy    = jsonencode(
#             {
#               + Statement = [
#                   + {
#                       + Action    = [
#                           + "sts:TagSession",
#                           + "sts:AssumeRole",
#                         ]
#                       + Effect    = "Allow"
#                       + Principal = {
#                           + Service = "eks.amazonaws.com"
#                         }
#                       + Sid       = "EKSClusterAssumeRole"
#                     },
#                 ]
#               + Version   = "2012-10-17"
#             }
#         )
#       + create_date           = (known after apply)
#       + force_detach_policies = true
#       + id                    = (known after apply)
#       + managed_policy_arns   = (known after apply)
#       + max_session_duration  = 3600
#       + name                  = (known after apply)
#       + name_prefix           = (known after apply)
#       + path                  = "/"
#       + tags_all              = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + unique_id             = (known after apply)

#       + inline_policy (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_iam_role_policy_attachment.cluster_encryption[0] will be created
#   + resource "aws_iam_role_policy_attachment" "cluster_encryption" {
#       + id         = (known after apply)
#       + policy_arn = (known after apply)
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_iam_role_policy_attachment.custom[0] will be created
#   + resource "aws_iam_role_policy_attachment" "custom" {
#       + id         = (known after apply)
#       + policy_arn = (known after apply)
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_security_group.cluster[0] will be created
#   + resource "aws_security_group" "cluster" {
#       + arn                    = (known after apply)
#       + description            = "EKS cluster security group"
#       + egress                 = (known after apply)
#       + id                     = (known after apply)
#       + ingress                = (known after apply)
#       + name                   = (known after apply)
#       + name_prefix            = (known after apply)
#       + owner_id               = (known after apply)
#       + revoke_rules_on_delete = false
#       + tags                   = (known after apply)
#       + tags_all               = (known after apply)
#       + vpc_id                 = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_security_group.node[0] will be created
#   + resource "aws_security_group" "node" {
#       + arn                    = (known after apply)
#       + description            = "EKS node shared security group"
#       + egress                 = (known after apply)
#       + id                     = (known after apply)
#       + ingress                = (known after apply)
#       + name                   = (known after apply)
#       + name_prefix            = (known after apply)
#       + owner_id               = (known after apply)
#       + revoke_rules_on_delete = false
#       + tags                   = (known after apply)
#       + tags_all               = (known after apply)
#       + vpc_id                 = (known after apply)
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.cluster["ingress_nodes_443"] will be created
#   + resource "aws_security_group_rule" "cluster" {
#       + description              = "Node groups to cluster API"
#       + from_port                = 443
#       + id                       = (known after apply)
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 443
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["egress_all"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + cidr_blocks              = [
#           + "0.0.0.0/0",
#         ]
#       + description              = "Allow all egress"
#       + from_port                = 0
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "-1"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 0
#       + type                     = "egress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_cluster_443"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Cluster API to node groups"
#       + from_port                = 443
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 443
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Cluster API to node 4443/tcp webhook"
#       + from_port                = 4443
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 4443
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Cluster API to node 6443/tcp webhook"
#       + from_port                = 6443
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 6443
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Cluster API to node 8443/tcp webhook"
#       + from_port                = 8443
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 8443
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Cluster API to node 9443/tcp webhook"
#       + from_port                = 9443
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 9443
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Cluster API to node kubelets"
#       + from_port                = 10250
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = false
#       + source_security_group_id = (known after apply)
#       + to_port                  = 10250
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Node to node ingress on ephemeral ports"
#       + from_port                = 1025
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = true
#       + source_security_group_id = (known after apply)
#       + to_port                  = 65535
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Node to node CoreDNS"
#       + from_port                = 53
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "tcp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = true
#       + source_security_group_id = (known after apply)
#       + to_port                  = 53
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be created
#   + resource "aws_security_group_rule" "node" {
#       + description              = "Node to node CoreDNS UDP"
#       + from_port                = 53
#       + id                       = (known after apply)
#       + prefix_list_ids          = []
#       + protocol                 = "udp"
#       + security_group_id        = (known after apply)
#       + security_group_rule_id   = (known after apply)
#       + self                     = true
#       + source_security_group_id = (known after apply)
#       + to_port                  = 53
#       + type                     = "ingress"
#     }

#   # module.aws-eks.module.eks.time_sleep.this[0] will be created
#   + resource "time_sleep" "this" {
#       + create_duration = "30s"
#       + id              = (known after apply)
#       + triggers        = {
#           + "cluster_certificate_authority_data" = (known after apply)
#           + "cluster_endpoint"                   = (known after apply)
#           + "cluster_name"                       = (known after apply)
#           + "cluster_service_cidr"               = (known after apply)
#           + "cluster_version"                    = "1.29"
#         }
#     }

#   # module.aws-eks.module.irsa-ebs-csi.data.aws_iam_policy_document.assume_role_with_oidc[0] will be read during apply
#   # (config refers to values not yet known)
#  <= data "aws_iam_policy_document" "assume_role_with_oidc" {
#       + id            = (known after apply)
#       + json          = (known after apply)
#       + minified_json = (known after apply)

#       + statement {
#           + actions = [
#               + "sts:AssumeRoleWithWebIdentity",
#             ]
#           + effect  = "Allow"

#           + condition {
#               + test     = "StringEquals"
#               + values   = [
#                   + "system:serviceaccount:kube-system:ebs-csi-controller-sa",
#                 ]
#               + variable = (known after apply)
#             }

#           + principals {
#               + identifiers = [
#                   + (known after apply),
#                 ]
#               + type        = "Federated"
#             }
#         }
#     }

#   # module.aws-eks.module.irsa-ebs-csi.aws_iam_role.this[0] will be created
#   + resource "aws_iam_role" "this" {
#       + arn                   = (known after apply)
#       + assume_role_policy    = (known after apply)
#       + create_date           = (known after apply)
#       + force_detach_policies = false
#       + id                    = (known after apply)
#       + managed_policy_arns   = (known after apply)
#       + max_session_duration  = 3600
#       + name                  = (known after apply)
#       + name_prefix           = (known after apply)
#       + path                  = "/"
#       + tags_all              = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + unique_id             = (known after apply)
#         # (1 unchanged attribute hidden)

#       + inline_policy (known after apply)
#     }

#   # module.aws-eks.module.irsa-ebs-csi.aws_iam_role_policy_attachment.custom[0] will be created
#   + resource "aws_iam_role_policy_attachment" "custom" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#       + role       = (known after apply)
#     }

  
#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].aws_eks_node_group.this[0] will be created
#   + resource "aws_eks_node_group" "this" {
#       + ami_type               = "AL2_x86_64"
#       + arn                    = (known after apply)
#       + capacity_type          = (known after apply)
#       + cluster_name           = (known after apply)
#       + disk_size              = (known after apply)
#       + id                     = (known after apply)
#       + instance_types         = [
#           + "t3.small",
#         ]
#       + node_group_name        = (known after apply)
#       + node_group_name_prefix = "node-group-1-"
#       + node_role_arn          = (known after apply)
#       + release_version        = (known after apply)
#       + resources              = (known after apply)
#       + status                 = (known after apply)
#       + subnet_ids             = (known after apply)
#       + tags                   = {
#           + "Name" = "node-group-1"
#         }
#       + tags_all               = {
#           + "Name"        = "node-group-1"
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + version                = "1.29"

#       + launch_template {
#           + id      = (known after apply)
#           + name    = (known after apply)
#           + version = (known after apply)
#         }

#       + node_repair_config (known after apply)

#       + scaling_config {
#           + desired_size = 2
#           + max_size     = 3
#           + min_size     = 1
#         }

#       + timeouts {}

#       + update_config {
#           + max_unavailable_percentage = 33
#         }
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].aws_iam_role.this[0] will be created
#   + resource "aws_iam_role" "this" {
#       + arn                   = (known after apply)
#       + assume_role_policy    = jsonencode(
#             {
#               + Statement = [
#                   + {
#                       + Action    = "sts:AssumeRole"
#                       + Effect    = "Allow"
#                       + Principal = {
#                           + Service = "ec2.amazonaws.com"
#                         }
#                       + Sid       = "EKSNodeAssumeRole"
#                     },
#                 ]
#               + Version   = "2012-10-17"
#             }
#         )
#       + create_date           = (known after apply)
#       + description           = "EKS managed node group IAM role"
#       + force_detach_policies = true
#       + id                    = (known after apply)
#       + managed_policy_arns   = (known after apply)
#       + max_session_duration  = 3600
#       + name                  = (known after apply)
#       + name_prefix           = "node-group-1-eks-node-group-"
#       + path                  = "/"
#       + tags_all              = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + unique_id             = (known after apply)

#       + inline_policy (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].aws_launch_template.this[0] will be created
#   + resource "aws_launch_template" "this" {
#       + arn                    = (known after apply)
#       + default_version        = (known after apply)
#       + description            = "Custom launch template for node-group-1 EKS managed node group"
#       + id                     = (known after apply)
#       + latest_version         = (known after apply)
#       + name                   = (known after apply)
#       + name_prefix            = "one-"
#       + tags_all               = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + update_default_version = true
#       + vpc_security_group_ids = (known after apply)
#         # (2 unchanged attributes hidden)

#       + metadata_options {
#           + http_endpoint               = "enabled"
#           + http_protocol_ipv6          = (known after apply)
#           + http_put_response_hop_limit = 2
#           + http_tokens                 = "required"
#           + instance_metadata_tags      = (known after apply)
#         }

#       + monitoring {
#           + enabled = true
#         }

#       + tag_specifications {
#           + resource_type = "instance"
#           + tags          = {
#               + "Name" = "node-group-1"
#             }
#         }
#       + tag_specifications {
#           + resource_type = "network-interface"
#           + tags          = {
#               + "Name" = "node-group-1"
#             }
#         }
#       + tag_specifications {
#           + resource_type = "volume"
#           + tags          = {
#               + "Name" = "node-group-1"
#             }
#         }
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].aws_eks_node_group.this[0] will be created
#   + resource "aws_eks_node_group" "this" {
#       + ami_type               = "AL2_x86_64"
#       + arn                    = (known after apply)
#       + capacity_type          = (known after apply)
#       + cluster_name           = (known after apply)
#       + disk_size              = (known after apply)
#       + id                     = (known after apply)
#       + instance_types         = [
#           + "t3.small",
#         ]
#       + node_group_name        = (known after apply)
#       + node_group_name_prefix = "node-group-2-"
#       + node_role_arn          = (known after apply)
#       + release_version        = (known after apply)
#       + resources              = (known after apply)
#       + status                 = (known after apply)
#       + subnet_ids             = (known after apply)
#       + tags                   = {
#           + "Name" = "node-group-2"
#         }
#       + tags_all               = {
#           + "Name"        = "node-group-2"
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + version                = "1.29"

#       + launch_template {
#           + id      = (known after apply)
#           + name    = (known after apply)
#           + version = (known after apply)
#         }

#       + node_repair_config (known after apply)

#       + scaling_config {
#           + desired_size = 1
#           + max_size     = 2
#           + min_size     = 1
#         }

#       + timeouts {}

#       + update_config {
#           + max_unavailable_percentage = 33
#         }
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].aws_iam_role.this[0] will be created
#   + resource "aws_iam_role" "this" {
#       + arn                   = (known after apply)
#       + assume_role_policy    = jsonencode(
#             {
#               + Statement = [
#                   + {
#                       + Action    = "sts:AssumeRole"
#                       + Effect    = "Allow"
#                       + Principal = {
#                           + Service = "ec2.amazonaws.com"
#                         }
#                       + Sid       = "EKSNodeAssumeRole"
#                     },
#                 ]
#               + Version   = "2012-10-17"
#             }
#         )
#       + create_date           = (known after apply)
#       + description           = "EKS managed node group IAM role"
#       + force_detach_policies = true
#       + id                    = (known after apply)
#       + managed_policy_arns   = (known after apply)
#       + max_session_duration  = 3600
#       + name                  = (known after apply)
#       + name_prefix           = "node-group-2-eks-node-group-"
#       + path                  = "/"
#       + tags_all              = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + unique_id             = (known after apply)

#       + inline_policy (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"] will be created
#   + resource "aws_iam_role_policy_attachment" "this" {
#       + id         = (known after apply)
#       + policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#       + role       = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].aws_launch_template.this[0] will be created
#   + resource "aws_launch_template" "this" {
#       + arn                    = (known after apply)
#       + default_version        = (known after apply)
#       + description            = "Custom launch template for node-group-2 EKS managed node group"
#       + id                     = (known after apply)
#       + latest_version         = (known after apply)
#       + name                   = (known after apply)
#       + name_prefix            = "two-"
#       + tags_all               = {
#           + "builder"     = "terraform"
#           + "environment" = "sandbox"
#         }
#       + update_default_version = true
#       + vpc_security_group_ids = (known after apply)
#         # (2 unchanged attributes hidden)

#       + metadata_options {
#           + http_endpoint               = "enabled"
#           + http_protocol_ipv6          = (known after apply)
#           + http_put_response_hop_limit = 2
#           + http_tokens                 = "required"
#           + instance_metadata_tags      = (known after apply)
#         }

#       + monitoring {
#           + enabled = true
#         }

#       + tag_specifications {
#           + resource_type = "instance"
#           + tags          = {
#               + "Name" = "node-group-2"
#             }
#         }
#       + tag_specifications {
#           + resource_type = "network-interface"
#           + tags          = {
#               + "Name" = "node-group-2"
#             }
#         }
#       + tag_specifications {
#           + resource_type = "volume"
#           + tags          = {
#               + "Name" = "node-group-2"
#             }
#         }
#     }

#   # module.aws-eks.module.eks.module.kms.data.aws_iam_policy_document.this[0] will be read during apply
#   # (config refers to values not yet known)
#  <= data "aws_iam_policy_document" "this" {
#       + id                        = (known after apply)
#       + json                      = (known after apply)
#       + minified_json             = (known after apply)
#       + override_policy_documents = []
#       + source_policy_documents   = []

#       + statement {
#           + actions   = [
#               + "kms:*",
#             ]
#           + resources = [
#               + "*",
#             ]
#           + sid       = "Default"

#           + principals {
#               + identifiers = [
#                   + "arn:aws:iam::656701891001:root",
#                 ]
#               + type        = "AWS"
#             }
#         }
#       + statement {
#           + actions   = [
#               + "kms:CancelKeyDeletion",
#               + "kms:Create*",
#               + "kms:Delete*",
#               + "kms:Describe*",
#               + "kms:Disable*",
#               + "kms:Enable*",
#               + "kms:Get*",
#               + "kms:ImportKeyMaterial",
#               + "kms:List*",
#               + "kms:Put*",
#               + "kms:ReplicateKey",
#               + "kms:Revoke*",
#               + "kms:ScheduleKeyDeletion",
#               + "kms:TagResource",
#               + "kms:UntagResource",
#               + "kms:Update*",
#             ]
#           + resources = [
#               + "*",
#             ]
#           + sid       = "KeyAdministration"

#           + principals {
#               + identifiers = [
#                   + "arn:aws:iam::656701891001:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_AWSAdministratorAccess_10f0e24f9e960885",
#                 ]
#               + type        = "AWS"
#             }
#         }
#       + statement {
#           + actions   = [
#               + "kms:Decrypt",
#               + "kms:DescribeKey",
#               + "kms:Encrypt",
#               + "kms:GenerateDataKey*",
#               + "kms:ReEncrypt*",
#             ]
#           + resources = [
#               + "*",
#             ]
#           + sid       = "KeyUsage"

#           + principals {
#               + identifiers = [
#                   + (known after apply),
#                 ]
#               + type        = "AWS"
#             }
#         }
#     }

#   # module.aws-eks.module.eks.module.kms.aws_kms_alias.this["cluster"] will be created
#   + resource "aws_kms_alias" "this" {
#       + arn            = (known after apply)
#       + id             = (known after apply)
#       + name           = (known after apply)
#       + name_prefix    = (known after apply)
#       + target_key_arn = (known after apply)
#       + target_key_id  = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.kms.aws_kms_key.this[0] will be created
#   + resource "aws_kms_key" "this" {
#       + arn                                = (known after apply)
#       + bypass_policy_lockout_safety_check = false
#       + customer_master_key_spec           = "SYMMETRIC_DEFAULT"
#       + description                        = (known after apply)
#       + enable_key_rotation                = true
#       + id                                 = (known after apply)
#       + is_enabled                         = true
#       + key_id                             = (known after apply)
#       + key_usage                          = "ENCRYPT_DECRYPT"
#       + multi_region                       = false
#       + policy                             = (known after apply)
#       + rotation_period_in_days            = (known after apply)
#       + tags                               = {
#           + "terraform-aws-modules" = "eks"
#         }
#       + tags_all                           = {
#           + "builder"               = "terraform"
#           + "environment"           = "sandbox"
#           + "terraform-aws-modules" = "eks"
#         }
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["one"].module.user_data.null_resource.validate_cluster_service_cidr will be created
#   + resource "null_resource" "validate_cluster_service_cidr" {
#       + id = (known after apply)
#     }

#   # module.aws-eks.module.eks.module.eks_managed_node_group["two"].module.user_data.null_resource.validate_cluster_service_cidr will be created
#   + resource "null_resource" "validate_cluster_service_cidr" {
#       + id = (known after apply)
#     }

