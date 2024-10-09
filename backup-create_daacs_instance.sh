#!/bin/bash


: '

1 - Pick instance type to create

    1: DAACS-Website
    2: DAACS-Qserver
    3: DAACS-Nginx
    4: DAACS-Backup 
    5: DAACS-Memcached

2 - 

'




#write to file with variable
destdir=/root/DAACS-setup-scripts/new-env-setups/woof
touch $destdir

if [ -f "$destdir" ]
then 
    echo "$var" > "$destdir"
fi

echo "woooff"

exit 1

#read file and print line by line
readarray -t arr < /root/DAACS-Install/DAACS-Website/env-dev/.env-dev-email

#new-env-setups
for i in "${arr[@]}"; do
    printf '%s\n' "$i"

done

exit 1


read -p "Enter base path for install of DAACS: " base_path
read -p "Enter folder name for install of DAACS: " install_folder
read -p "Enter folder name for install of DAACS webserver: " web_server_path
read -p "Enter folder name for install of DAACS frontend: " frontend_path
read -p "Enter folder path to DAACS install scripts/env files: " env_instance_path

if [ "$web_server_path" = "" ]; 
then
    web_server_path="DAACS-Webserver"
fi

if [ "$frontend_path" = "" ]; then
    frontend_path="DAACS-Frontend"
fi

if [ "$env_instance_path" = "" ]; then
    echo "MISSING install folder path"
    exit -1
fi

# # printf "base_path: $base_path  \n web_server_path: $web_server_path  \n frontend_path: $frontend_path  \n env_instance_path: $env_instance_path  \n"

# #check to see if nginx is running if not exit 0 because we need nginx to run 
if  test $(docker ps --filter "name=nginx-proxy" | wc -l) -le 1 
then
    echo "Missing NGINX"
    exit 1
fi 

# echo $(test -d $env_instance_path)

# exit 1

if  ! $(test -d $env_instance_path) ;
# if  ! (( $(test -d "$env_instance_path") )) ;
then
    echo "MISSING install folder path"
    exit -1
fi

cd $base_path
git clone git@github.com:moomoo-dev/DAACS-Website.git "$base_path/$install_folder"


#one liner
cd "$base_path/$install_folder/$web_server_path" && npm ci && cd "../$frontend_path/" &&  npm ci 

# Fill out .env-prod-webserver, .env-prod-webserver-mongo, .env-prod-webserver-mongo-init, .env-prod-queueserver, .env-prod-queuemongo-init, .env-prod-queuemongo, .env-prod-oauth, config/webconfig.js

# sudo $(cat ../install/env-prod/.env-prod-oauth) npx ember build --prod
# export $(cat ./install/env-prod/.env-prod-webserver ./install/env-prod/.env-prod-webserver-mongo) && docker compose -f ./install/yml/Docker-Webserver-prod.docker.yml up -d
# export $(cat ./install/env-prod/.env-prod-queueserver ./install/env-prod/.env-prod-queuemongo) && docker compose -f ./install/yml/Docker-Queueserver.prod.yml up -d
# export $(cat ./install/env-prod/.env-prod-digitalocean) && docker compose -f ./install/yml/Docker-Export.prod.yml up -d

