resource "aws_iam_role" "lambda-exec_role" {
  name = "lambda_s3_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-s3_policy_attach" {
  role       = aws_iam_role.lambda-exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_lambda_function" "lambda-tratar_imagem" {
  function_name = "tratar_imagem"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda-exec_role.arn
  filename      = "tratar_imagem.zip"

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.s3-tratada.bucket
    }
  }
}

resource "aws_s3_bucket_notification" "lambda-upload_image_notification" {
  bucket = aws_s3_bucket.s3-original.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-tratar_imagem.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-tratar_imagem.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-original.arn
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-tratar_imagem.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-reconhecida.arn
}