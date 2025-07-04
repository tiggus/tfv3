resource "aws_s3_bucket" "sftp" {
  bucket = "sftp-${random_id.random.hex}"

  tags = {
    Name = "sftp-${random_id.random.hex}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm s3://${self.bucket} --recursive"
  }
}

# resource "aws_s3_bucket_cors_configuration" "sftp" {
#   bucket                = aws_s3_bucket.sftp.bucket
#   expected_bucket_owner = null
#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["DELETE", "GET", "HEAD", "POST", "PUT"]
#     allowed_origins = ["${awscc_transfer_web_app.webapp.access_endpoint}"]
#     expose_headers  = ["access-control-expose-headers", "content-length", "content-type", "date", "etag", "last-modified", "x-amz-cf-id", "x-amz-id-2", "x-amz-request-id", "x-amz-storage-class", "x-amz-version-id"]
#     id              = null
#     max_age_seconds = 3000
#   }
# }

resource "aws_s3_object" "folder" {
  count  = length(var.sftp_users)
  bucket = aws_s3_bucket.sftp.id
  key    = "${var.sftp_users[count.index]}/"
}

resource "aws_s3control_access_grants_instance" "s3" {
  account_id          = "656701891001"
  identity_center_arn = data.aws_ssoadmin_instances.root.arns[0]
  tags                = null
}

resource "aws_s3control_access_grants_location" "s3" {
  depends_on = [aws_s3control_access_grants_instance.s3]

  iam_role_arn   = aws_iam_role.access.arn
  location_scope = "s3://"
}


resource "aws_s3control_access_grant" "s3" {
  access_grants_location_id = aws_s3control_access_grants_location.s3.access_grants_location_id
  permission                = "READWRITE"

  access_grants_location_configuration {
    s3_sub_prefix = "${aws_s3_bucket.sftp.bucket}/*"
  }

  grantee {
    grantee_type       = "DIRECTORY_GROUP"
    grantee_identifier = data.aws_identitystore_group.identitystore.group_id
  }
}
