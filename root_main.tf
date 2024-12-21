provider "aws" {
  region = "ap-south-1"
}

# Generate SSH Key Pair using Terraform (TLS provider)
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create an AWS EC2 key pair using the generated public key
resource "aws_key_pair" "key" {
  key_name   = "webserver-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Security Group
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-053b12d3152c0cc71" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key.key_name

  security_groups = [
    aws_security_group.web_sg.name
  ]

  # Provisioner to install Nginx
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable nginx1",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

  tags = {
    Name = "WebServer"
  }
}

# Output
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
