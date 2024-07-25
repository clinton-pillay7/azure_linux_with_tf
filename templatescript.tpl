#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker ubuntu


sudo apt-get install python-pip
mkdir dockercontent
cd dockercontent
wget https://dockercontent.blob.core.windows.net/docker-content/Dockerfile
wget https://dockercontent.blob.core.windows.net/docker-content/flaskapp.py
wget https://dockercontent.blob.core.windows.net/docker-content/requirements.txt
sudo docker build -t flask-hello-world .
sudo docker run -p 5000:5000 flask-hello-world