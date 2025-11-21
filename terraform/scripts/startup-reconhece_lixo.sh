#!/bin/bash
set -e

sudo apt update -y && sudo apt upgrade -y

sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull uken49/reconhece-lixo:latest
sudo docker run -d --name reconhece-lixo --restart=unless-stopped -p 80:80 -e BUCKET_RECONHECIDA="${BUCKET_RECONHECIDA}" uken49/reconhece-lixo:latest