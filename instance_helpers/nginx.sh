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

    read -p "Enter name for mongo service (todo check for clashes before moving on): " nginx_service_name
    read -p "Enter default email for lets encrypt: " default_email_input

    if [ "$nginx_service_name" = "" ]; then
        echo "Cannot leave docker nginx service name empty."
        exit -1
    fi

    if [ "$default_email_input" = "" ]; then
        echo "Cannot leave default email empty."
        exit -1
    fi

    # # env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$1")
    root_dest="$install_root/new-env-setups"

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$foldername"
    if  ! $(test -d "$root_dest/$nginx_service_name/docker/") ;
    then
        mkdir -p "$root_dest/$nginx_service_name/docker/"
    fi

    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-nginx-prod.docker.yml"
        ;;
        "env-prod") 
            docker_file="Docker-nginx-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac
    # # copy docker file to new location to save for later use
    nginx_docker_file_from="$install_env_path/${instance_type_defintion}/docker/$docker_file"
    nginx_docker_file_to="${root_dest}/${nginx_service_name}/docker/${docker_file}"
 
    nginx_files_from="$install_env_path/${instance_type_defintion}/docker/nginx"
    nginx_files_to="${root_dest}/${nginx_service_name}/docker/nginx"
    cp -r "${nginx_files_from}" "${nginx_files_to}"

     
    nginx_files_from="$install_env_path/${instance_type_defintion}/docker/Dockerfile-ngnix"
    nginx_files_to="${root_dest}/${nginx_service_name}/docker/Dockerfile-ngnix"
    cp "${nginx_files_from}" "${nginx_files_to}"
    

    cp "${nginx_docker_file_from}" "${nginx_docker_file_to}"
    sed  -i -e "s/#nginx_service_name/$nginx_service_name/g" "$nginx_docker_file_to"

    default_email="DEFAULT_EMAIL=$default_email_input"
    env_string="${default_email} "
    
    run_docker_with_envs "$nginx_docker_file_to" "$env_string"
}