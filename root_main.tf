provider "aws" {
  region = var.aws_region
}


# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2SecurityGroup"
  }
}

# EC2 Instance
resource "aws_instance" "ec2" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name    = "MyEC2Instance5"
    Version = var.version_name
  }
}
  # Use a provisioner to wait for SSH to be ready
  provisioner "remote-exec" {
    inline = [
      "echo 'Instance is ready for SSH'"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = aws_security_group.ec2_sg.name
      host        = self.public_ip
    }
  }

  # Install and Configure Nginx
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable nginx1",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.key_pair.private_key_pem
      host        = self.public_ip
    }
  }

  tags = {
    Name = "WebServer"
  }
}

# Output the Public IP of the Instance
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
