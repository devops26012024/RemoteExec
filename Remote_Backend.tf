terraform {
  backend "s3" {
    bucket         = "pradeep-terraform-1234333"
    key            = "remote-exec/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tera-demo"
    encrypt        = true
  }
}
