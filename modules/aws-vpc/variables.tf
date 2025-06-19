# variable "private_subnet_ids" {
#   type = map(object({
#     ids = string
#   }))
# }

variable "private_subnet_ids" {
  type = list(string)
  default = []
}

# variable "public_subnets" {
#   description = "A list of public subnets inside the VPC"
#   type        = list(string)
#   default     = []
# }



variable "create_vpc" {
  type    = bool
  default = false
}

variable "manage_nacl" {
  type    = bool
  default = false
}

variable "manage_route_table" {
  type    = bool
  default = false
}

variable "manage_security_group" {
  type    = bool
  default = false
}

variable "create_public_subnets" {
  type    = bool
  default = false
}

variable "create_igw" {
  type    = bool
  default = false
}

variable "create_private_subnets" {
  type    = bool
  default = false
}

variable "enable_dns_hostnames" {
  type    = bool
  default = false
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "ip_cidr_range" {
  type = string
}

variable "ip_private_subnets" {
  type = list(string)
}

variable "ip_public_subnets" {
  type = list(string)
}

variable "default_nacl_ingress" {
  type = list(map(string))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "default_nacl_egress" {
  type = list(map(string))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "default_routes" {
  type    = list(map(string))
  default = []
}

variable "default_sg_ingress" {
  type        = list(map(string))
  default     = []
}

variable "default_sg_egress" {
  type        = list(map(string))
  default     = []
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
}

variable "create_private_ngw_route" {
  type        = bool
  default     = true
}

variable "ngw_destination_cidr_block" {
  type        = string
  default     = "0.0.0.0/0"
}
