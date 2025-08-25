# Empacotando o código Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../application/tratamento-imagem.py"
  output_path = "${path.module}/tratamento-imagem.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda_tratar_imagem" {
  function_name = "tratar_imagem"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  role          = "arn:aws:iam::${var.ACCOUNT_ID}:role/labrole"
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.s3-tratada.bucket
    }
  }
}

# Permissão Lambda para ser invocada pelo bucket original
resource "aws_lambda_permission" "allow_s3_original" {
  statement_id  = "AllowS3InvokeOriginal"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_tratar_imagem.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-original.arn
}

# Notificação do bucket original para Lambda
resource "aws_s3_bucket_notification" "lambda_upload_image_notification" {
  bucket = aws_s3_bucket.s3-original.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_tratar_imagem.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3_original
  ]
}