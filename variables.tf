variable "cluster_root" {
  type    = string
  default = "eks-cluster"
}

variable "vpc_root" {
  type    = string
  default = "eks-vpc"
}

variable "ip_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "ip_private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type    = set(string)
}

variable "ip_public_subnets" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  type    = set(string)
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "ip_cidr_range_euw1" {
  type    = string
  default = "10.1.0.0/16"
}

variable "ip_private_subnets_euw1" {
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  type    = set(string)
}

variable "ip_public_subnets_euw1" {
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  type    = set(string)
}




