variable "private_subnet_ids" {
  type        = list(string)
  default     = []
}

# variable "control_plane_subnet_ids" {
#   type        = list(string)
#   default     = []
# }











variable "account_id" {
  type = string
}

variable "cluster_root" {
  type = string
}

locals {
  cluster_name = "${var.cluster_root}-${random_string.suffix.result}"
}

variable "create_cluster" {
  type    = bool
  default = false
}

variable "cluster_version" {
  description = "<major>.<minor>` eks version"
  type        = string
  default     = null
}

variable "authentication_mode" {
  description = "CONFIG_MAP, API or API_AND_CONFIG_MAP"
  type        = string
  default     = null
}

# locals {
#   availability_zones = data.aws_availability_zones.available
# }