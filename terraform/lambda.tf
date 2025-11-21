data "archive_file" "lambda-fluxo_tratamento" {
    type        = "zip"
    source_file = "scripts/fluxo_tratamento.py"
    output_path = "lambda_files/fluxo_tratamento.zip"
}

data "archive_file" "lambda-trigger_envio_modelo" {
    type        = "zip"
    source_file = "scripts/trigger_envio_modelo.py"
    output_path = "lambda_files/trigger_envio_modelo.zip"
}

resource "aws_lambda_function" "lambda-fluxo_tratamento" {
    filename      = data.archive_file.lambda-fluxo_tratamento.output_path
    function_name = "tratar_imagem_fluxo"
    role          = "arn:aws:iam::${var.ACCOUNT_ID}:role/LabRole"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"
    architectures = ["x86_64"]

    layers = [
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-boto3:22",
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-Pillow:7"
    ]

    environment {
        variables = {
            BUCKET_DESTINO = aws_s3_bucket.s3-tratada.bucket
        }
    }

    vpc_config {
        subnet_ids         = [aws_subnet.public-tcc-east_1a.id, aws_subnet.public-tcc-east_1b.id]
        security_group_ids = [aws_security_group.sg-lambda.id]
    }
}

resource "aws_lambda_function" "lambda-trigger_envio_modelo" {
    filename      = data.archive_file.lambda-trigger_envio_modelo.output_path
    function_name = "trigger_envio_modelo"
    role          = "arn:aws:iam::${var.ACCOUNT_ID}:role/LabRole"
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.12"
    architectures = ["x86_64"]

    layers = [
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-boto3:22"
    ]
    environment {
        variables = {
            ENDPOINT_MODELO = "http://${aws_instance.ec2-reconhece_lixo.private_ip}:80/api/reconhece/v1"
        }
    }

    vpc_config {
        subnet_ids         = [aws_subnet.public-tcc-east_1a.id, aws_subnet.public-tcc-east_1b.id] # ajuste
        security_group_ids = [aws_security_group.sg-lambda.id]
    }
}

resource "aws_lambda_permission" "allow_s3_original" {
    statement_id  = "AllowS3InvokeOriginal"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda-fluxo_tratamento.function_name
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.s3-original.arn
}

resource "aws_s3_bucket_notification" "lambda_upload_image_notification" {
    bucket = aws_s3_bucket.s3-original.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.lambda-fluxo_tratamento.arn
        events              = ["s3:ObjectCreated:Put"]
    }

    depends_on = [
        aws_lambda_permission.allow_s3_original
    ]
}
