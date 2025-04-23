# Tópico SNS
resource "aws_sns_topic" "image_processed_notification" {
  name = "image-processed-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.image_processed_notification.arn
  protocol  = "email"
  endpoint  = "helder.alvarenga@sptech.school"
}

resource "aws_s3_bucket_notification" "processed_image_notification" {
  bucket = aws_s3_bucket.processed_bucket.id

  topic {
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "processed/"
    topic_arn     = aws_sns_topic.image_processed_notification.arn
  }
}