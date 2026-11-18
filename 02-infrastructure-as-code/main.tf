terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " ~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "northstar_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "northstar_vpc"
    Project = "northstar-infrastructure"
  }
}

resource "aws_subnet" "northstar_public_subnet" {
  vpc_id                  = aws_vpc.northstar_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "northstar-public-subnet"
    Project = "northstar-infrastructure"
  }
}

resource "aws_internet_gateway" "northstar_igw" {
  vpc_id = aws_vpc.northstar_vpc.id

  tags = {
    Name    = "northstar-igw"
    Project = "northstar-infrastructure"
  }
}

resource "aws_route_table" "northstar_public_rt" {
  vpc_id = aws_vpc.northstar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.northstar_igw.id
  }

  tags = {
    Name    = "northstar-public-aws_route_table"
    Project = "northstar-infrastructure"
  }
}

resource "aws_route_table_association" "northstar_public_assoc" {
  subnet_id      = aws_subnet.northstar_public_subnet.id
  route_table_id = aws_route_table.northstar_public_rt.id
}

resource "aws_security_group" "northstar_web_sg" {
  name        = "northstar-web-sg"
  description = "Security group for Northstar web server"
  vpc_id      = aws_vpc.northstar_vpc.id

  tags = {
    Name    = "northstar-web-sg"
    Project = "northstar-infrastructure"
  }
}

resource "aws_vpc_security_group_ingress_rule" "northstar_http" {
  security_group_id = aws_security_group.northstar_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "northstar_outbound" {
  security_group_id = aws_security_group.northstar_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_iam_role" "northstar_ec2_role" {
  name = "northstar-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "northstar-infrastructure"
  }
}

resource "aws_iam_role_policy_attachment" "northstar_ssm_policy" {
  role       = aws_iam_role.northstar_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "northstar_ec2_profile" {
  name = "northstar-ec2-ssm-profile"
  role = aws_iam_role.northstar_ec2_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "northstar_web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.northstar_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.northstar_web_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.northstar_ec2_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update
    apt-get install -y apache2
    systemctl enable --now apache2

    echo "<h1>Northstar Infrastructure - Managed by Terraform</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name    = "northstar-web-server"
    Project = "northstar-infrastructure"
  }
}