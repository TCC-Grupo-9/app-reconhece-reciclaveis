import boto3
import os
from PIL import Image
from io import BytesIO

s3 = boto3.client("s3")

def lambda_handler(event, context):
    bucket_origem = event["Records"][0]["s3"]["bucket"]["name"]
    chave_origem = event["Records"][0]["s3"]["object"]["key"]
    bucket_destino = "tcc-tratada-bucket"

    try:
        nome_arquivo = os.path.basename(chave_origem)
        email = nome_arquivo.split("-")[0]

        extensao = os.path.splitext(nome_arquivo)[1].lower().replace(".", "")
        formato = "JPEG" if extensao in ["jpg", "jpeg"] else extensao.upper()

        response = s3.get_object(Bucket=bucket_origem, Key=chave_origem)
        img_bytes = response["Body"].read()

        img = Image.open(BytesIO(img_bytes))

        largura = 640
        proporcao = largura / float(img.width)
        altura = int(float(img.height) * proporcao)

        img = img.resize((largura, altura), Image.Resampling.LANCZOS)

        buffer = BytesIO()
        img.save(buffer, format=formato, optimize=True, quality=85)
        buffer.seek(0)

        s3.put_object(Bucket=bucket_destino, Key=nome_arquivo, Body=buffer)

        return {
            "statusCode": 200,
            "guid": email,
            "mensagem": f"Imagem tratada enviada para {bucket_destino}/{nome_arquivo}"
        }

    except Exception as e:
        print(f"Erro ao processar {chave_origem}: {str(e)}")
        return {
            "statusCode": 500,
            "erro": str(e)
        }