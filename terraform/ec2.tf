resource "aws_key_pair" "tcc_key" {
  key_name   = "tcc-key"
  public_key = file("ssh/tcc-key.pub")
}

resource "aws_instance" "ec2-reconhece_lixo" {
    ami                    = "ami-0ecb62995f68bb549"
    instance_type          = "t3.micro"
    subnet_id              = aws_subnet.public-tcc-east_1a.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sg-backend.id]

    key_name = aws_key_pair.tcc_key.key_name
    
    user_data = templatefile("scripts/startup-reconhece_lixo.sh", {
        BUCKET_RECONHECIDA = aws_s3_bucket.s3-reconhecida.bucket
    })

    tags = {
        Name        = "reconhece-lixo"
        Product     = "tcc"
        Environment = "prod"
    }
}

resource "aws_instance" "ec2-tcc_gateway" {
    ami                    = "ami-0ecb62995f68bb549"
    instance_type          = "t3.micro"
    subnet_id              = aws_subnet.public-tcc-east_1b.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sg-backend.id]

    key_name = aws_key_pair.tcc_key.key_name

    user_data = templatefile("scripts/startup-tcc_gateway.sh", {
        BUCKET_ORIGINAL = aws_s3_bucket.s3-original.bucket
    })

    tags = {
        Name        = "tcc-gateway"
        Product     = "tcc"
        Environment = "prod"
    }
}
