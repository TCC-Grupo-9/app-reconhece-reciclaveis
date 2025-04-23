# Tópico SNS
resource "aws_sns_topic" "sns-imagem_reconhecida" {
  name = "imagem-reconhecida-topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "SNS:Publish",
        Resource = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:imagem-reconhecida-topic",
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.s3-reconhecida.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email-inscricao" {
  topic_arn = aws_sns_topic.sns-imagem_reconhecida.arn
  protocol  = "email"
  endpoint  = "helder.alvarenga@sptech.school"
}

resource "aws_s3_bucket_notification" "notification-imagem_reconhecida" {
  bucket = aws_s3_bucket.s3-reconhecida.id

  topic {
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "processed/"
    topic_arn     = aws_sns_topic.sns-imagem_reconhecida.arn
  }
}