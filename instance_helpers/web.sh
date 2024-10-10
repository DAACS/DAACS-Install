#!/bin/bash
. ./instance_helpers/basic.sh

: '
Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'


write_service_subsititions_to_docker_file(){

    instance_type_defintion=$1
    install_folder_destination=$2
    base_path_folder_destination=$3
    web_server_path=$4
    frontend_path=$5
    install_env_path=$6
    environment_type_defintion=$7
    mongo_service_name=$8
    webserver_service_name=$9
    root_dest="$PWD/new-env-setups"


    docker_file=""

        case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Webserver-dev.docker.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Webserver-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    # # copy docker file to new location to save for later use
    webserver_docker_file="$PWD/DAACS-Install-Defaults/${instance_type_defintion}/docker/$docker_file"
    cp "${webserver_docker_file}" "${root_dest}/${install_folder_destination}/docker/${docker_file}"

    webserver_docker_file="$root_dest/$install_folder_destination/docker/$docker_file"
    sed  -i -e "s/#mongo_service_name/$mongo_service_name/g ; s/#webserver_service_name/$webserver_service_name/g" "$webserver_docker_file"

    # # /var/www/html/               /football                      /DAACS-Webserver
    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    # #/root/DAACS-Install/DAACS-Install-Defaults /DAACS-Webserver 
    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    #todo make these come from input file dynamically
    assessments_env="ASSESSMENTS=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"
    port="PORT=80"
    replicas="REPLICAS=1"
    mongo_container_name="MONGODB_CONTAINER_NAME=newbranchmongo"
    

    # # run docker file - webserver
    catted="${assessments_env} ${folder_start_env} ${env_dir} ${port} ${replicas} ${mongo_container_name}"
    catted+=" docker compose -f ${webserver_docker_file} up -d"
    eval "$catted"

    printf "%s\n" "$catted"
    
}

create_web_instance_helper(){

    instance_type=$1
    install_env_path=$2
    environment_type=$3

    printf "\nCREATING Web instance....\n"

    read -p "Enter absolute path destination for install of DAACS: " base_path_folder_destination
    read -p "Enter folder destination for install of DAACS: " install_folder_destination
    read -p "Enter folder name for install of DAACS web server (Relative to install path): " web_server_path
    read -p "Enter folder name for install of DAACS frontend (Relative to install path): " frontend_path
    read -p "Enter name for mongo service (todo check for clashes before moving on): " mongo_service_name
    read -p "Enter name for web service (todo check for clashes before moving on): " webserver_service_name
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

    if [ "$mongo_service_name" = "" ]; then
        echo "Cannot leave docker mongo service name empty."
        exit -1
    fi

    if [ "$webserver_service_name" = "" ]; then
        echo "Cannot leave docker web service name empty."
        exit -1
    fi
    

    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$1")

    # write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$base_path_folder_destination" "$web_server_path" "$frontend_path" "$install_env_path" "$environment_type_defintion" "$mongo_service_name" "$webserver_service_name"
    
    # exit 1


    # # Create env files for install
    IFS=' ' read -ra ADDR <<< "$env_to_create"
    for i in "${ADDR[@]}"; do
        filename=$(basename "$i")
        retval=$( fill_out_env_file "$i")
        write_env_to_file $retval $environment_type_defintion $install_folder_destination $filename
    done

    root_dest="$PWD/new-env-setups"

    # # get code from repo
    cd $base_path_folder_destination
    git clone git@github.com:moomoo-dev/DAACS-Website.git "$base_path_folder_destination/$install_folder_destination"
    
    # # # # install node modules for web server
    cd "$base_path_folder_destination/$install_folder_destination/$web_server_path/" 
    npm ci 

    # # # # install node modules for frontend
    cd "$base_path_folder_destination/$install_folder_destination/$frontend_path/"
    npm ci 

    # Fill out .env-prod-webserver, .env-prod-webserver-mongo, .env-prod-webserver-mongo-init, .env-prod-oauth, config/webconfig.js

    # # build frontend
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    # # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${absolute_dir}webserver-mongo-init"
    # # filename - enviroment variables for oauth
    env_oauth_file="${absolute_dir}oauth"

    catted=$(cat "${env_oauth_file}") npx ember build --prod
    $catted

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$foldername"
    if  ! $(test -d "$root_dest/$install_folder_destination/docker/") ;
    then
        mkdir -p "$root_dest/$install_folder_destination/docker/"
    fi

    write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$base_path_folder_destination" "$web_server_path" "$frontend_path" "$install_env_path" "$environment_type_defintion" "$mongo_service_name" "$webserver_service_name"

    exit 1
}