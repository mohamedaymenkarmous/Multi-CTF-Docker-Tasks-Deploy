#!/bin/bash

cd
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker ubuntu

# get latest docker compose released tag
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

sudo systemctl status docker

# Will be decomissionned since there is no need to locally install nginx server
#sudo apt install -y nginx
#systemctl status nginx
#sudo apt-get install -y git
#git clone https://github.com/mohamedaymenkarmous/nginx-config
#sudo cp -R /etc/nginx /etc/nginx-$(date +%s).bak
#sudo mkdir /etc/nginx/ssl
#sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
#sudo cp nginx-config/conf.d/ssl_settings.conf /etc/nginx/conf.d/
