# VPC, Subnets, e outros recursos necessários para a infraestrutura de rede
resource "aws_vpc" "vpc-tcc" {
  cidr_block = "10.0.0.0/26"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc-tcc"
    Product     = "tcc"
    Environment = "prod"
  }
}

# Associação para adicionar um CIDR secundário
resource "aws_vpc_ipv4_cidr_block_association" "vpc-tcc_additional_cidr" {
  vpc_id     = aws_vpc.vpc-tcc.id
  cidr_block = "10.1.0.0/26"
}

resource "aws_subnet" "public-tcc-east_1a" {
  vpc_id                  = aws_vpc.vpc-tcc.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "subnet_public-east_1a"
    Product     = "tcc"
    Environment = "prod"
  }
}

resource "aws_subnet" "public-tcc-east_1b" {
  vpc_id                  = aws_vpc.vpc-tcc.id
  cidr_block              = "10.1.0.0/28"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc-tcc_additional_cidr
  ]

  tags = {
    Name        = "subnet_public-east_1b"
    Product     = "tcc"
    Environment = "prod"
  }
}


resource "aws_internet_gateway" "igw-tcc" {
  vpc_id = aws_vpc.vpc-tcc.id

  tags = {
    Name        = "igw-tcc"
    Product     = "tcc"
    Environment = "prod"
  }
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc-tcc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-tcc.id
  }

  tags = {
    Name = "rtb-public"
  }
}

resource "aws_route_table_association" "rta-public-1a" {
  subnet_id      = aws_subnet.public-tcc-east_1a.id
  route_table_id = aws_route_table.rtb-public.id
}

resource "aws_route_table_association" "rta-public-1b" {
  subnet_id      = aws_subnet.public-tcc-east_1b.id
  route_table_id = aws_route_table.rtb-public.id
}