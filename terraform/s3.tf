# S3 Bucket
resource "aws_s3_bucket" "s3-original" {
  bucket = "tcc-bucket-original"
}

resource "aws_s3_bucket" "s3-tratada" {
  bucket = "tcc-bucket-tratada"
}

resource "aws_s3_bucket" "s3-reconhecida" {
  bucket = "tcc-bucket-reconhecida"
}