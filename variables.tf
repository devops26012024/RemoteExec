variable "aws_region" {
  default = "ap-south-1"
}

variable "aws_ami" {
  default = "ami-053b12d3152c0cc71"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "secret_name" {
  description = "The name of secret in AWS Secrets Manager"
  type = string
  default = "prod/db/credentials"
  }
