resource "aws_instance" "web" {

  ami                    = "ami-022ce6f32988af5fa"
  instance_type          = "t2.micro"
  key_name               = "DevOps"
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
      private_key = file("/Users/balajireddylachhannagari/Downloads/DevOps.pem")
    }
    inline = ["sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo chmod 777 -R /var/www"
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
