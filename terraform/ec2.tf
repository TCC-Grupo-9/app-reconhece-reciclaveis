# EC2
resource "aws_instance" "ec2-postgres_fastlog" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name      = "key-michael-kaiser"

  user_data = file("scripts/script.sh")

  tags = {
    Name        = "postgres_fastlog"
    Product     = "fastlog"
    Environment = "prod"
  }
}