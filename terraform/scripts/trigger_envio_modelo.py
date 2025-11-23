import boto3
from io import BytesIO
import os
import requests

s3 = boto3.client("s3")

ENDPOINT_MODELO = os.environ.get("ENDPOINT_MODELO")  

def lambda_handler(event, context):
    try:
        bucket = event["Records"][0]["s3"]["bucket"]["name"]
        key = event["Records"][0]["s3"]["object"]["key"]
        print("Bucket:", bucket)
        print("Key:", key)

        response = s3.get_object(Bucket=bucket, Key=key)
        print("Response:", response)
        imagem_bytes = response["Body"].read()

        metadata = response.get("Metadata", {})
        email = metadata.get("email") or ""
        webhook = metadata.get("webhook") or ""

        files = {
            "imagem": (key, imagem_bytes, "image/jpg")
        }

        data = {
            "email": email,
            "webhook": webhook,
            "filename": key,
            "bucket": bucket
        }

        ecs_response = requests.post(
            ENDPOINT_MODELO,
            data=data,
            params={
                "email": email,
                "webhook": webhook
            },
            files=files,
            timeout=30
        )

        print("Resposta endpoint:", ecs_response.text)

        return {
            "statusCode": 200,
            "email": email,
            "webhook": webhook,
            "bucket": bucket,
        }

    except Exception as e:
        print("ERRO:", str(e))
        return {
            "statusCode": 500,
            "erro": str(e)
        }
