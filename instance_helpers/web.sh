#!/bin/bash
. ./instance_helpers/basic.sh

: '
Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'
create_web_instance_helper(){

    instance_type=$1
    install_env_path=$2
    environment_type=$3

    printf "\nCREATING Web instance....\n"

    read -p "Enter folder destination for install of DAACS: " install_folder_destination
    read -p "Enter absolute path destination for install of DAACS: " base_path_folder_destination
    read -p "Enter folder name for install of DAACS web server (Relative to install path): " web_server_path
    read -p "Enter folder name for install of DAACS frontend (Relative to install path):: " frontend_path
    # read -p "Enter folder path to DAACS install scripts/env files: " env_instance_path

    if [ "$install_folder_destination" = "" ]; 
    then
        echo "Please choose an install destination."
        exit 1
    fi

    if [ "$web_server_path" = "" ]; 
    then
        web_server_path="DAACS-Webserver"
    fi

    if [ "$frontend_path" = "" ]; then
        frontend_path="DAACS-Frontend"
    fi

    # env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    # environment_type_defintion=$(get_env_type_definition "$environment_type")

    # IFS=' ' read -ra ADDR <<< "$env_to_create"

    # # Print each element of the array
    # for i in "${ADDR[@]}"; do
    #     filename=$(basename "$i")
    #     retval=$( fill_out_env_file "$i")
    #     write_env_to_file $retval $environment_type_defintion $install_folder_destination $filename
    # done

    root_dest="$PWD/new-env-setups"
    env_path_base="$root_dest/$install_folder_destination/$environment_type_defintion/"
    env_path="$env_path_base$environment_type_defintion-"
    # cat "${env_path}email"
    # # get code from repo
    # cd $base_path_folder_destination
    # git clone git@github.com:moomoo-dev/DAACS-Website.git "$base_path_folder_destination/$install_folder_destination"

    # # # install node modules
    # cd "$base_path_folder_destination/$install_folder_destination" 
    # # cd "$web_server_path/"
    # # npm ci 
    # cd "$frontend_path/"
    # # npm ci 

    # Fill out .env-prod-webserver, .env-prod-webserver-mongo, .env-prod-webserver-mongo-init, .env-prod-queueserver, .env-prod-queuemongo-init, .env-prod-queuemongo, .env-prod-oauth, config/webconfig.js

    # # build frontend
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    # oauth="${absolute_dir}oauth"
    # catted=$(cat "${oauth}") npx ember build --prod
    # $catted


    webserver="${absolute_dir}webserver"
    webserver_mongo="${absolute_dir}webserver-mongo"
    instance_type=$(get_instance_type_definition "$instance_type")

    webserver_docker_file="${root_dest}/${instance_type}/Docker-Webserver-prod.docker.yml"
    echo $webserver_docker_file
    # catted=export $(cat ./install/env-prod/.env-prod-webserver ./install/env-prod/.env-prod-webserver-mongo) && docker compose -f ./install/yml/Docker-Webserver-prod.docker.yml up -d

    # export $(cat ./install/env-prod/.env-prod-queueserver ./install/env-prod/.env-prod-queuemongo) && docker compose -f ./install/yml/Docker-Queueserver.prod.yml up -d
    # export $(cat ./install/env-prod/.env-prod-digitalocean) && docker compose -f ./install/yml/Docker-Export.prod.yml up -d


}