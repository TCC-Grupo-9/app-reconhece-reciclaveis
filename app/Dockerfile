FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
COPY best.pt /app/best.pt
COPY app.py /app/app.py

RUN pip install --no-cache-dir -r requirements.txt


EXPOSE 80   

CMD ["python", "app.py"]
