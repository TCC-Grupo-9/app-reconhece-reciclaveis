#!/bin/bash
set -e

sudo apt update -y && sudo apt upgrade -y

sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull uken49/tcc-gateway:latest
sudo docker run -d --name tcc-gateway --restart=unless-stopped -p 80:8080 -e BUCKET_ORIGINAL="${BUCKET_ORIGINAL}" -e REGION=us-east-1 uken49/tcc-gateway:latest