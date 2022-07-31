# Install VM's modified from Leon Robinson

provider "aws" {
  region = "eu-west-2"
}

// Input Variables

variable "sshkeypairname" {
  type        = string
  description = "ssh keypair name in aws"
}

variable "small"  {
  default = "t2.small"
}

variable "micro"  {
  default = "t2.micro"
}

// Local Variables

locals {
  imageid      = "ami-0bd2099338bc55e6d"
}


resource "aws_security_group" "nginx" {
  name = "petclinic-nginx"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name = "petclinic-app"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 9966
    to_port     = 9966
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dev" {
  name = "petclinic-dev"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 9966
    to_port     = 9966
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Services"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_instance" "dev" {
  ami                    = local.imageid
  instance_type          = var.small
  key_name               = var.sshkeypairname
  vpc_security_group_ids = [aws_security_group.dev.id]
  user_data              = <<EOF
#cloud-config
sources:
  ansible:
    source "ppa:ansible/ansible"
packages:
  - software-properties-common
  - ansible
runcmd:
  - git clone https://github.com/Jamalh8/petclinic-setup.git /tmp/petclinic-setup


EOF

  root_block_device {
    volume_size = 20
  }
  tags = {
    Name = "Petclinic-Dev"
  }
}

resource "aws_instance" "nginx" {
  ami                    = local.imageid
  instance_type          = var.micro
  key_name               = var.sshkeypairname
  vpc_security_group_ids = [aws_security_group.nginx.id]
  user_data              = <<EOF
#cloud-config
package_upgrade: true
sources:
  ansible:
    source "ppa:ansible/ansible"
packages:
  - software-properties-common
  - ansible
runcmd:
  - git clone https://github.com/Jamalh8/petclinic-setup.git /tmp/petclinic-setup
EOF

  root_block_device {
    volume_size = 8
  }
  tags = {
    Name = "Petclinic-Nginx"
  }
}

resource "aws_instance" "app" {
  ami                    = local.imageid
  instance_type          = var.small
  key_name               = var.sshkeypairname
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = <<EOF
#cloud-config
package_upgrade: true
sources:
  ansible:
    source "ppa:ansible/ansible"
packages:
  - software-properties-common
  - ansible
runcmd:
  - git clone https://github.com/Jamalh8/petclinic-setup.git /tmp/petclinic-setup
EOF

  root_block_device {
    volume_size = 15
  }
  tags = {
    Name = "Petclinic-App"
  }
}

output "App_IP" {
  value = aws_instance.app.public_ip
}

output "Nginx_IP" {
  value = aws_instance.nginx.public_ip
}

output "Dev_IP" {
  value = aws_instance.dev.public_ip
}
