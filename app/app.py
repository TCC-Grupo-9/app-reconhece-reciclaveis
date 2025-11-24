import base64
import boto3
from flask import Flask, request, jsonify
from ultralytics import YOLO
from PIL import Image
import io
import json
import os

model = YOLO("/app/best.pt")

s3 = boto3.client("s3")
BUCKET_RECONHECIDA = os.environ.get("BUCKET_RECONHECIDA")

app = Flask(__name__)
app.config["PROPAGATE_EXCEPTIONS"] = True

def detecta(imagem):
    resultados = model(imagem)
    boxes = resultados[0].boxes

    classes = boxes.cls.tolist()
    confs = boxes.conf.tolist()
    names = resultados[0].names

    detectados = []
    for cls, conf in zip(classes, confs):
        detectados.append({
            "classe": names[int(cls)],
            "probabilidade": float(conf)
        })

    print("Detectados:", detectados)

    img_reconhecida = resultados[0].plot()
    pil_result = Image.fromarray(img_reconhecida)

    return detectados, pil_result


def envio_s3(buffer, img_name, email, webhook, detectados):
    print(f"Fazendo upload para S3: s3://{BUCKET_RECONHECIDA}/{img_name}")

    metadata = {
        "detectados": json.dumps(detectados)
    }

    if email:
        metadata["email"] = email
    if webhook:
        metadata["webhook"] = webhook

    s3.upload_fileobj(
        buffer,
        BUCKET_RECONHECIDA,
        img_name,
        ExtraArgs={
            "ContentType": "image/jpeg",
            "Metadata": metadata
        }
    )

    print("Upload concluído")


@app.route("/api/reconhece/v1", methods=["POST"])
def reconhece():
    email = request.args.get("email") or ""
    webhook = request.args.get("webhook") or ""

    if "imagem" not in request.files:
        return jsonify({"erro": "Envie uma imagem no form-data"}), 400

    img_file = request.files["imagem"]

    img_name = img_file.filename
    print(f"Recebido arquivo: {img_name}")

    pil_img = Image.open(img_file.stream).convert("RGB")

    detectados, pil_result = detecta(pil_img)

    buffer = io.BytesIO()
    pil_result.save(buffer, format="JPEG")
    buffer.seek(0)

    envio_s3(buffer, img_name, email, webhook, detectados)

    return jsonify({"detectados": detectados})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)