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

variable "identity_store_group_local" {
  default = "user-entapp-sftp-sandbox"
}

# variable "identity_store_group" {
#   default = "user-entapp-sftp-sandbox"
# }

variable "sftp_users" {
  type    = list(string)
  default = ["jon", "jane"]
}
