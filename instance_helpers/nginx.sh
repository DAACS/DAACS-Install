#!/bin/bash 

# docker network create nginx-proxy
# docker network create myNetwork

# # If apache, or anything is listening on port 80 you have to stop it 
# sudo ss -lptn 'sport = :80' && sudo systemctl stop apache2 && sudo systemctl disable apache2

# #nginx instance 
# docker compose -f ./install/yml/Docker-ngnix-prod.yml up -d


create_nginx_instance_helper(){

    instance_type=$1
    install_env_path=$2 #/root/DAACS-Install/DAACS-Install_Defaults
    environment_type=$3
    install_root=$4 #/root/DAACS-Install

    printf "\nCREATING nginx instance....\n"

    read -p "Enter absolute path destination for install of DAACS: " base_path_folder_destination
    read -p "Enter folder destination for install of DAACS: " install_folder_destination
    read -p "Enter name for mongo service (todo check for clashes before moving on): " mongo_service_name
    
    if [ "$install_folder_destination" = "" ]; 
    then
        echo "Please choose an install destination."
        exit 1
    fi

    if [ "$mongo_service_name" = "" ]; then
        echo "Cannot leave docker mongo service name empty."
        exit -1
    fi

    if [ "$qserver_service_name" = "" ]; then
        echo "Cannot leave docker Q service name empty."
        exit -1
    fi
    

}