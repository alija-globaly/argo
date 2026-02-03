output "core_security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.main_security_group.id
  //value = [for security_group in aws_security_group.web-sg : security_group.id]
}