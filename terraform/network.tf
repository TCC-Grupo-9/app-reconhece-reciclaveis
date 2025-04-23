# VPC, Subnets, e outros recursos necessários para a infraestrutura de rede
resource "aws_vpc" "vpc-fastlog" {
  cidr_block = "10.0.0.0/26"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc-fastlog"
    Product     = "fastlog"
    Environment = "prod"
  }
}

# Associação para adicionar um CIDR secundário
resource "aws_vpc_ipv4_cidr_block_association" "vpc-fastlog_additional_cidr" {
  vpc_id     = aws_vpc.vpc-fastlog.id
  cidr_block = "10.1.0.0/26"
}

resource "aws_subnet" "public-fastlog-east_1a" {
  vpc_id                  = aws_vpc.vpc-fastlog.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "subnet_public-east_1a"
    Product     = "fastlog"
    Environment = "prod"
  }
}

resource "aws_subnet" "public-fastlog-east_1b" {
  vpc_id                  = aws_vpc.vpc-fastlog.id
  cidr_block              = "10.1.0.0/28"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "subnet_public-east_1b"
    Product     = "fastlog"
    Environment = "prod"
  }
}