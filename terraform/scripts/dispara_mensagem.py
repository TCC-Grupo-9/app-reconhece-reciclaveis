import boto3
import json
import os
import requests

# TOPICO_SNS = os.environ.get("TOPICO_SNS")
BUCKET_RECONHECIDA = os.environ.get("BUCKET_RECONHECIDA")
s3 = boto3.client("s3")
# sns = boto3.client("sns")

def gerar_presigned_url(bucket, key):
    url = s3.generate_presigned_url(
        "get_object",
        Params={"Bucket": bucket, "Key": key},
        ExpiresIn=7200
    )
    return url

def lambda_handler(event, context):
    try:
        bucket_origem = event["Records"][0]["s3"]["bucket"]["name"]
        chave_origem = event["Records"][0]["s3"]["object"]["key"]

        nome_arquivo = os.path.basename(chave_origem)
        response = s3.get_object(Bucket=bucket_origem, Key=chave_origem)
        metadata = response.get("Metadata", {})

        email = metadata.get("email") or ""
        webhook = metadata.get("webhook") or ""
        detectados_raw = metadata.get("detectados", "[]")
        detectados = json.loads(detectados_raw)

        url_imagem = gerar_presigned_url(BUCKET_RECONHECIDA, nome_arquivo)

        # if email:
        #     try:
        #         mensagem_email = (
        #             f"{json.dumps(detectados, indent=4)}\n"
        #             f"Imagem: {url_imagem}"
        #         )

        #         resposta_email = sns.publish(
        #             TopicArn=TOPICO_SNS,
        #             Message=mensagem_email,
        #             Subject="Resultado da Análise da Imagem"
        #         )

        #         print("Resposta do SNS:", resposta_email)
        #     except Exception as e:
        #         print("Erro ao enviar e-mail:", str(e))

        if webhook:
            try:
                resposta_webhook = requests.post(
                    webhook,
                    json={
                        "imagem": url_imagem,
                        "detectados": detectados
                    },
                    timeout=3
                )
                print("Resposta do Webhook:", resposta_webhook.text)
            except Exception as e:
                print("Erro ao enviar webhook:", str(e))

        return {"statusCode": 200}

    except Exception as e:
        print("ERRO:", str(e))
        return {"statusCode": 500, "erro": str(e)}
