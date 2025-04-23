# S3 Bucket
resource "aws_s3_bucket" "s3-original" {
  bucket = "fastlog-original-bucket"
}

resource "aws_s3_bucket" "s3-tratada" {
  bucket = "fastlog-tratada-bucket"
}

resource "aws_s3_bucket" "s3-reconhecida" {
  bucket = "fastlog-reconhecida-bucket"
}