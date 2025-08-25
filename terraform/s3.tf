# S3 Bucket
resource "aws_s3_bucket" "s3-original" {
  bucket = "tcc-original-bucket"
}

resource "aws_s3_bucket" "s3-tratada" {
  bucket = "tcc-tratada-bucket"
}

resource "aws_s3_bucket" "s3-reconhecida" {
  bucket = "tcc-reconhecida-bucket"
}