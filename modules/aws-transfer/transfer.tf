resource "aws_transfer_server" "transfer" {
  identity_provider_type = "SERVICE_MANAGED"
  protocol_details {
    set_stat_option = "ENABLE_NO_OP"
  }
  tags = {
    Name = "transfer${random_id.random.hex}"
  }
}

resource "tls_private_key" "transfer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "key${random_id.random.hex}"
  public_key = tls_private_key.transfer.public_key_openssh
}

resource "aws_transfer_ssh_key" "transfer" {
  count     = length(var.sftp_users)
  server_id = aws_transfer_server.transfer.id
  user_name = aws_transfer_user.transfer[count.index].user_name
  body      = trimspace(tls_private_key.transfer.public_key_openssh)
}

resource "aws_transfer_user" "transfer" {
  count     = length(var.sftp_users)
  server_id = aws_transfer_server.transfer.id
  user_name = "${var.sftp_users[count.index]}${random_id.random.hex}"
  role      = aws_iam_role.transfer[count.index].arn

  home_directory_type = "PATH"
  home_directory      = "/${aws_s3_bucket.sftp.id}/${var.sftp_users[count.index]}"
}
