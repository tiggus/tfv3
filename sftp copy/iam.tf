# resource "aws_iam_role" "transfer" {
#   count              = length(var.sftp_users)
#   name               = "${var.sftp_users[count.index]}${random_id.random.hex}"
#   assume_role_policy = data.aws_iam_policy_document.service.json
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

# resource "aws_iam_role_policy" "transfer" {
#   count  = length(var.sftp_users)
#   name   = "${var.sftp_users[count.index]}${random_id.random.hex}"
#   role   = aws_iam_role.transfer[count.index].id
#   policy = data.aws_iam_policy_document.transfer[count.index].json
# }

# data "aws_iam_policy_document" "transfer" {
#   count = length(var.sftp_users)
#   statement {
#     sid    = "HomeDirObjectAccess"
#     effect = "Allow"
#     actions = [
#       "s3:PutObject",
#       "s3:GetObject",
#       "s3:GetObjectTagging",
#       "s3:DeleteObject",
#       "s3:DeleteObjectVersion",
#       "s3:GetObjectVersion",
#       "s3:GetObjectVersionTagging",
#       "s3:GetObjectACL",
#       "s3:ListBucket",
#       "s3:PutObjectACL",
#       "s3:GetBucketLocation"
#     ]

#     resources = ["${aws_s3_bucket.sftp.arn}/${var.sftp_users[count.index]}/*"]
#   }
# }


data "aws_iam_policy_document" "access" {
  statement {
    sid    = "ObjectLevelReadPermissions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectAcl",
      "s3:GetObjectVersionAcl",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["arn:aws:s3:::*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"

      values = [
        "656701891001",

      ]
    }
  }
}

resource "aws_iam_policy" "access" {
  name   = "transfer-${random_id.random.hex}"
  policy = data.aws_iam_policy_document.access.json
}






resource "aws_iam_role_policy_attachment" "access" {
  role       = aws_iam_role.access.id
  policy_arn = aws_iam_policy.access.arn
}


resource "aws_iam_role" "access" {
  name               = "access_grant_${random_id.random.hex}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:SetContext"]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com", "access-grants.s3.amazonaws.com"]
    }
  }
}





#     condition = 

#                 "StringEquals": {
#                     "aws:ResourceAccount": "656701891001"
#                 },
#                 "ArnEquals": {
#                     "s3:AccessGrantsInstanceArn": [
#                         "arn:aws:s3:eu-west-2:656701891001:access-grants/default"
#                     ]
#                 }
#             }
#         },
#         {
#             "Sid": "ObjectLevelWritePermissions",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:PutObject",
#                 "s3:PutObjectAcl",
#                 "s3:PutObjectVersionAcl",
#                 "s3:DeleteObject",
#                 "s3:DeleteObjectVersion",
#                 "s3:AbortMultipartUpload"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::*"
#             ],
#             "Condition": {
#                 "StringEquals": {
#                     "aws:ResourceAccount": "656701891001"
#                 },
#                 "ArnEquals": {
#                     "s3:AccessGrantsInstanceArn": [
#                         "arn:aws:s3:eu-west-2:656701891001:access-grants/default"
#                     ]
#                 }
#             }
#         },
#         {
#             "Sid": "BucketLevelReadPermissions",
#             "Effect": "Allow",
#             "Action": [
#                 "s3:ListBucket"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::*"
#             ],
#             "Condition": {
#                 "StringEquals": {
#                     "aws:ResourceAccount": "656701891001"
#                 },
#                 "ArnEquals": {
#                     "s3:AccessGrantsInstanceArn": [
#                         "arn:aws:s3:eu-west-2:656701891001:access-grants/default"
#                     ]
#                 }
#             }
#         }
#     ]
# }

# resource "aws_iam_role" "access" {
#   name               = "access-grants${random_id.random.hex}"
#   assume_role_policy = data.aws_iam_policy_document.transfer[0].json
# }


# {
#     "Version": "2012-10-17",

# }


# {
# 	"Version": "2012-10-17",
# 	"Statement": [
# 		{
# 			"Sid": "AccessGrantsTrustPolicy",
# 			"Effect": "Allow",
# 			"Principal": {
# 				"Service": "access-grants.s3.amazonaws.com"
# 			},
# 			"Action": [
# 				"sts:AssumeRole",
# 				"sts:SetSourceIdentity"
# 			],
# 			"Condition": {
# 				"StringEquals": {
# 					"aws:SourceArn": "arn:aws:s3:eu-west-2:656701891001:access-grants/default",
# 					"aws:SourceAccount": "656701891001"
# 				}
# 			}
# 		},
# 		{
# 			"Sid": "AccessGrantsTrustPolicyWithIDCContext",
# 			"Effect": "Allow",
# 			"Principal": {
# 				"Service": "access-grants.s3.amazonaws.com"
# 			},
# 			"Action": "sts:SetContext",
# 			"Condition": {
# 				"StringEquals": {
# 					"aws:SourceArn": "arn:aws:s3:eu-west-2:656701891001:access-grants/default",
# 					"aws:SourceAccount": "656701891001"
# 				},
# 				"ForAllValues:ArnEquals": {
# 					"sts:RequestContextProviders": "arn:aws:iam::aws:contextProvider/IdentityCenter"
# 				}
# 			}
# 		}
# 	]
# }


