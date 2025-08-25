import boto3
import os
from PIL import Image
import tempfile

s3 = boto3.client("s3")

def lambda_handler(event, context):
    # 1. Pega informações do arquivo enviado
    bucket_origem = event["Records"][0]["s3"]["bucket"]["name"]
    chave_origem = event["Records"][0]["s3"]["object"]["key"]

    bucket_destino = os.environ["OUTPUT_BUCKET"]
    chave_destino = f"resized-{os.path.basename(chave_origem)}"

    try:
        # 2. Cria pasta temporária
        with tempfile.TemporaryDirectory() as tmpdir:
            arquivo_origem = os.path.join(tmpdir, "input_image")
            arquivo_saida = os.path.join(tmpdir, "output_image.jpg")

            # Baixa do S3
            s3.download_file(bucket_origem, chave_origem, arquivo_origem)

            # 3. Abre e redimensiona imagem
            with Image.open(arquivo_origem) as img:
                largura = 640
                proporcao = largura / float(img.width)
                altura = int(float(img.height) * proporcao)

                img = img.resize((largura, altura), Image.Resampling.LANCZOS)
                img.save(arquivo_saida, optimize=True, quality=85)

            # 4. Sobe imagem redimensionada para bucket destino
            s3.upload_file(arquivo_saida, bucket_destino, chave_destino)

        return {
            "statusCode": 200,
            "body": f"Imagem redimensionada enviada para {bucket_destino}/{chave_destino}"
        }

    except Exception as e:
        print(f"Erro ao processar {chave_origem}: {str(e)}")
        raise e
