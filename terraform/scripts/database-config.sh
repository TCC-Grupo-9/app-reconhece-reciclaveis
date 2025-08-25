#!/bin/bash
echo "Iniciando setup" > /var/log/setup.log
sudo apt update -y
sudo apt install -y postgresql