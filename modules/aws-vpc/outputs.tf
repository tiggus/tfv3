output "availability_zones" {
  description = "aws availability sones"
  value       = data.aws_availability_zones.available.names
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_id" {
  value = aws_vpc.vpc[0].id
}

output "public_route" {
  value = aws_route_table.public[0].id
}

output "private_route" {
  value = aws_route_table.private[0].id
}


