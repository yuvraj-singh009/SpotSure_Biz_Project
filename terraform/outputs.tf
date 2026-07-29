output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "elastic_ip" {
  description = "Permanent public IP (<ELASTIC_IP> in the rest of the assignment)"
  value       = aws_eip.this.public_ip
}

output "private_key_path" {
  description = "Path to the generated .pem file — treat like the console-downloaded key"
  value       = local_sensitive_file.private_key_pem.filename
}

output "ssh_command" {
  description = "Ready-to-use SSH command"
  value       = "ssh -i ${local_sensitive_file.private_key_pem.filename} ubuntu@${aws_eip.this.public_ip}"
}

output "security_group_id" {
  description = "ID of the devops-chat-sg security group"
  value       = aws_security_group.this.id
}
