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

data "archive_file" "lambda-dispara_mensagem" {
    type        = "zip"
    source_file = "scripts/dispara_mensagem.py"
    output_path = "lambda_files/dispara_mensagem.zip"
}

resource "aws_lambda_function" "lambda-fluxo_tratamento" {
    filename      = data.archive_file.lambda-fluxo_tratamento.output_path
    function_name = "tratar_imagem_fluxo"
    role          = "arn:aws:iam::${var.ACCOUNT_ID}:role/LabRole"
    handler       = "fluxo_tratamento.lambda_handler"
    runtime       = "python3.12"
    architectures = ["x86_64"]
    memory_size = 1024
    timeout     = 10

    layers = [
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-boto3:22",
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-Pillow:7"
    ]

    environment {
        variables = {
            BUCKET_ORIGINAL = aws_s3_bucket.s3-tratada.bucket
        }
    }
}

resource "aws_lambda_function" "lambda-trigger_envio_modelo" {
    filename      = data.archive_file.lambda-trigger_envio_modelo.output_path
    function_name = "trigger_envio_modelo"
    role          = "arn:aws:iam::${var.ACCOUNT_ID}:role/LabRole"
    handler       = "trigger_envio_modelo.lambda_handler"
    runtime       = "python3.12"
    architectures = ["x86_64"]
    memory_size = 1024
    timeout     = 10

    layers = [
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-boto3:22",
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-requests:17"
    ]

    environment {
        variables = {
            ENDPOINT_MODELO = "http://${aws_instance.ec2-reconhece_lixo.private_ip}:80/api/reconhece/v1"
        }
    }
}

resource "aws_lambda_function" "lambda-dispara_mensagem" {
    filename      = data.archive_file.lambda-dispara_mensagem.output_path
    function_name = "dispara_mensagem"
    role          = "arn:aws:iam::${var.ACCOUNT_ID}:role/LabRole"
    handler       = "dispara_mensagem.lambda_handler"
    runtime       = "python3.12"
    architectures = ["x86_64"]
    memory_size = 1024
    timeout     = 10

    layers = [
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-boto3:22",
        "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-requests:17"
    ]

    environment {
        variables = {
            BUCKET_RECONHECIDA = aws_s3_bucket.s3-reconhecida.bucket
        }
    }
}

resource "aws_lambda_permission" "allow_s3_original" {
    statement_id  = "AllowS3InvokeOriginal"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda-fluxo_tratamento.function_name
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.s3-original.arn
}

resource "aws_lambda_permission" "allow_s3_tratada" {
    statement_id  = "AllowS3InvokeTratada"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda-trigger_envio_modelo.function_name
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.s3-tratada.arn
}

resource "aws_lambda_permission" "allow_s3_reconhecida" {
    statement_id  = "AllowS3InvokeReconhecida"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda-dispara_mensagem.function_name
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.s3-reconhecida.arn
}
