# S3 Bucket
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "fastlog-upload-bucket"
}

resource "aws_s3_bucket" "resized_bucket" {
  bucket = "fastlog-resized-bucket"
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = "fastlog-processed-bucket"
}