provider "aws" {
  region = var.aws_region
}

data "aws_secretsmanager_secret" "example" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = data.aws_secretsmanager_secret.example.id
}

output "retrieved_secret" {
  value = prod/db/credentials
  sensitive = true
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Web Server SG allow SSH & HTTP Ports"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For testing; restrict to your IP for production.
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
    description = "Allow all out bound ports to all destinations"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  key_name      = "guru"

  security_groups = [ aws_security_group.web_sg.name ]

  tags = {
    "Name"      = "Web_Server"
    "ManagedBy" = "IaC"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("./guru.pem")
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
    on_failure = continue
  }

}

