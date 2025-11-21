import boto3
from io import BytesIO
import os
from PIL import Image

s3 = boto3.client("s3")

BUCKET_ORIGINAL = os.environ.get("BUCKET_ORIGINAL")  

def lambda_handler(event, context):
    bucket_origem = event["Records"][0]["s3"]["bucket"]["name"]
    chave_origem = event["Records"][0]["s3"]["object"]["key"]

    try:
        nome_arquivo = os.path.basename(chave_origem)

        response = s3.get_object(Bucket=bucket_origem, Key=chave_origem)
        metadata = response.get("Metadata", {})

        email = metadata.get("email") or ""
        webhook = metadata.get("webhook") or ""

        img_bytes = response["Body"].read()
        img = Image.open(BytesIO(img_bytes))

        largura = 640
        proporcao = largura / float(img.width)
        altura = int(float(img.height) * proporcao)
        img = img.resize((largura, altura), Image.Resampling.LANCZOS)

        buffer = BytesIO()
        formato = img.format or "PNG"
        img.save(buffer, format=formato, optimize=True, quality=85)
        buffer.seek(0)

        s3.put_object(
            Bucket=BUCKET_ORIGINAL,
            Key=nome_arquivo,
            Body=buffer,
            Metadata={
                "email": email,
                "webhook": webhook
            }
        )

        return {
            "statusCode": 200,
            "email": email,
            "webhook": webhook,
            "destino": f"{BUCKET_ORIGINAL}/{nome_arquivo}"
        }

    except Exception as e:
        print(f"Erro ao processar {chave_origem}: {str(e)}")
        return {
            "statusCode": 500,
            "erro": str(e)
        }