output "db-instance_ip" {
  value = aws_instance.db-instance.public_ip
}

output "api-instance_ip" {
  value = aws_instance.api-instance.public_ip
}

