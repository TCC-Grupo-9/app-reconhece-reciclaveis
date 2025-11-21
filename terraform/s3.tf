# S3 Bucket
resource "aws_s3_bucket" "s3-original" {
  bucket = "imagem-original-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "s3-tratada" {
  bucket = "imagem-tratada-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "s3-reconhecida" {
  bucket = "imagem-reconhecida-${random_id.suffix.hex}"
}