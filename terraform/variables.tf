variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "devops-chat-server"
}

variable "instance_type" {
  description = "EC2 instance type (free-tier eligible)"
  type        = string
  default     = "t3.micro"
}



variable "security_group_name" {
  description = "Name for the EC2 security group"
  type        = string
  default     = "devops-chat-sg"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB (8 GiB is free-tier eligible)"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "my_ip_cidr" {
  description = <<-EOT
    Your current public IP in CIDR form (e.g. "203.0.113.4/32"), used to
    restrict SSH initially. Find it with `curl -s ifconfig.me`.
    Ignored once widen_ssh_to_anywhere = true (Part 11.1).
  EOT
  type        = string
}

variable "widen_ssh_to_anywhere" {
  description = <<-EOT
    Set to true to open SSH (port 22) to 0.0.0.0/0, matching Part 11.1 —
    required so GitHub Actions runners (rotating IPs) can reach the box
    over SSH for CI/CD. Leave false until you actually need that pipeline.
  EOT
  type        = bool
  default     = true
}
