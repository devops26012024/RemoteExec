resource "aws_instance" "web" {

  ami                    = "ami-053b12d3152c0cc71"
  instance_type          = "t2.micro"
  key_name               = "guru"
  vpc_security_group_ids = [aws_security_group.websg.id]

  tags = {
    "Name"      = "Web_Server"
    "ManagedBy" = "IaC"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("/Users/pradeepkumar.dodda/Downloads/guru.pem")
    }
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable nginx1",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
    on_failure = continue
  }

}

resource "aws_security_group" "websg" {
  name        = "webserver-sg"
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
