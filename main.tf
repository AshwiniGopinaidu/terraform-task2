# =========================================================================
# REGION 1: US-EAST-1
# =========================================================================

# Fetch latest Ubuntu AMI for us-east-1
data "aws_ami" "ubuntu_east" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Security Group for us-east-1
resource "aws_security_group" "sg_east" {
  name        = "nginx-sg-east"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance in us-east-1
resource "aws_instance" "nginx_east" {
  ami                    = data.aws_ami.ubuntu_east.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_east.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Server-US-East"
  }
}

# =========================================================================
# REGION 2: US-WEST-2 (Uses the 'us-west-2' provider alias)
# =========================================================================

# Fetch latest Ubuntu AMI for us-west-2
data "aws_ami" "ubuntu_west" {
  provider    = aws.us-west-2
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Security Group for us-west-2
resource "aws_security_group" "sg_west" {
  provider    = aws.us-west-2
  name        = "nginx-sg-west"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance in us-west-2
resource "aws_instance" "nginx_west" {
  provider               = aws.us-west-2
  ami                    = data.aws_ami.ubuntu_west.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_west.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Nginx-Server-US-West"
  }
}

# =========================================================================
# OUTPUTS
# =========================================================================

output "east_instance_public_ip" {
  value       = aws_instance.nginx_east.public_ip
  description = "The public IP of the EC2 instance in us-east-1"
}

output "west_instance_public_ip" {
  value       = aws_instance.nginx_west.public_ip
  description = "The public IP of the EC2 instance in us-west-2"
}
