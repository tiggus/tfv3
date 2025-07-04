resource "aws_iam_account_alias" "alias" {
  account_alias = "${var.account_name}-${var.account_env}${random_id.random.hex}"
}

resource "random_id" "random" {
  byte_length = 4
}
