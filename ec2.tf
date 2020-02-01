provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  count         = "2"
  instance_type = "t2.micro"
  key_name      = "us-east-1-keypair"
}
