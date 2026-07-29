# ---------------------------------------------------------------------------
# AMI: Ubuntu Server 24.04 LTS (Noble), amd64, HVM, EBS-backed — Canonical's
# official account. Always resolved dynamically so the AMI ID stays current.
# ---------------------------------------------------------------------------
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ---------------------------------------------------------------------------
# Key pair: generated in Terraform (RSA, 4096-bit) instead of via the console
# "Create new key pair" wizard. The private key is written locally as a .pem
# with 0400 permissions — treat it exactly like the console-downloaded file:
# back it up, never commit it.
# ---------------------------------------------------------------------------
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "devops-chat-key" 
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_sensitive_file" "private_key_pem" {
  content         = tls_private_key.this.private_key_pem
  # Change var.key_pair_name to reference the resource directly:
  filename        = "${path.module}/${aws_key_pair.this.key_name}.pem"
  file_permission = "0400"
}

# ---------------------------------------------------------------------------
# Security group: devops-chat-sg
#   - SSH (22): starts restricted to my_ip_cidr, matches Part 9's "My IP"
#     source; flip widen_ssh_to_anywhere to true to apply Part 11.1 and open
#     it to 0.0.0.0/0 for GitHub Actions runners.
#   - HTTP (80): open to the world from the start, per Part 9.
# ---------------------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = "Security group for devops-chat-server"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.widen_ssh_to_anywhere ? ["0.0.0.0/0"] : [var.my_ip_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# ---------------------------------------------------------------------------
# EC2 instance
# ---------------------------------------------------------------------------
resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = {
    Name = var.instance_name
  }
}

# ---------------------------------------------------------------------------
# Elastic IP: allocated and associated together, so one never sits idle
# racking up the hourly "unattached EIP" charge mentioned in Part 6.1.
# ---------------------------------------------------------------------------
resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = {
    Name = "${var.instance_name}-eip"
  }
}
