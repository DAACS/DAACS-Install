#!/bin/bash 

docker network create nginx-proxy
docker network create myNetwork

# If apache, or anything is listening on port 80 you have to stop it 
sudo ss -lptn 'sport = :80' && sudo systemctl stop apache2 && sudo systemctl disable apache2

#nginx instance 
docker compose -f ./install/yml/Docker-ngnix-prod.yml up -d