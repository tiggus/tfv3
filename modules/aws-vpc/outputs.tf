output "availability_zones" {
  description = "aws availability sones"
  value       = data.aws_availability_zones.available.names
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
