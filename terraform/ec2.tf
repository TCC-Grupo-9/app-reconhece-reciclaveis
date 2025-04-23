# EC2
resource "aws_instance" "ec2-db_fastlog" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"

  tags = {
    Name        = "db-prod_fastlog"
    Product     = "fastlog"
    Environment = "prod"
  }

  key_name = "key-mick-jagger"
}
