variable "account_name" {
  type    = string
  default = "devops"
}

variable "account_env" {
  type    = string
  default = "sandbox"
}

variable "identity_store_group" {
  default = "ebs-devops"
}

variable "sftp_users" {
  type    = list(string)
  default = ["jon", "jane"]
}
