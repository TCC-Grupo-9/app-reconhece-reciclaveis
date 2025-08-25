# Tópico SNS
variable "sns_topic_arn" {
  default = "arn:aws:sns:us-east-1:824365303792:imagem-reconhecida-topic"
}

resource "aws_s3_bucket_notification" "notification-imagem_reconhecida" {
  bucket = aws_s3_bucket.s3-reconhecida.id

  topic {
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "processed/"
    topic_arn     = "arn:aws:sns:us-east-1:824365303792:imagem-reconhecida-topic"
  }
}