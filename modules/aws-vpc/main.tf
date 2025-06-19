resource "aws_vpc" "vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.ip_cidr_range
  instance_tenancy     = "default"
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
}

resource "aws_subnet" "public" {
  count                           = var.create_public_subnets ? (length(var.ip_public_subnets)) : 0
  vpc_id                          = aws_vpc.vpc[0].id
  cidr_block                      = var.ip_public_subnets[count.index]
  availability_zone               = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation = false
}

resource "aws_subnet" "private" {
  count                           = var.create_private_subnets ? (length(var.ip_private_subnets)) : 0
  vpc_id                          = aws_vpc.vpc[0].id
  cidr_block                      = var.ip_private_subnets[count.index]
  availability_zone               = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation = false
}

resource "aws_default_network_acl" "acl" {
  count                  = var.create_vpc && var.manage_nacl ? 1 : 0
  default_network_acl_id = aws_vpc.vpc[0].default_network_acl_id
  subnet_ids = null
  dynamic "ingress" {
    for_each = var.default_nacl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.default_nacl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }
  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_route_table" "route" {
  count = var.create_vpc && var.manage_route_table ? 1 : 0
  default_route_table_id = aws_vpc.vpc[0].default_route_table_id
  dynamic "route" {
    for_each = var.default_routes
    content {
      cidr_block                = route.value.cidr_block
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }
  timeouts {
    create = "5m"
    update = "5m"
  }
}

resource "aws_default_security_group" "security" {
  count = var.create_vpc && var.manage_security_group ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
  dynamic "ingress" {
    for_each = var.default_sg_ingress
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }
  dynamic "egress" {
    for_each = var.default_sg_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }
}

resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  count = var.create_public_subnets && var.create_igw ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
}

resource "aws_nat_gateway" "nat" {
  count = var.create_vpc && var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id = aws_subnet.public[0].id
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_ngw" {
  count = var.create_vpc && var.enable_nat_gateway && var.create_private_ngw_route ? 1 : 0
  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.ngw_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table" "private" {
  count = var.create_private_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
}

resource "aws_route" "public_igw" {
  count = var.create_public_subnets && var.create_igw ? 1 : 0
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table" "public" {
  count = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
}

resource "aws_route_table_association" "public" {
  count = var.create_public_subnets ? (length(var.ip_public_subnets)) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}


resource "aws_route_table_association" "private" {
  count = var.create_private_subnets ? (length(var.ip_private_subnets)) : 0
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
