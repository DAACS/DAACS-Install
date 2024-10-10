#!/bin/bash

# ./DAACS-Install-Defaults - folder for default .env files
. ./instance_helpers/web.sh
. ./instance_helpers/basic.sh

: '
1 - Pick instance type to create

    1: DAACS-Website
    2: DAACS-Qserver
    3: DAACS-Nginx
    4: DAACS-Backup 
    5: DAACS-Memcached

2 - Type envirmoment type to create
3 - Enter base path for install of DAACS



'

read -p "
    1 - DAACS-Website
    2 - DAACS-Qserver
    3 - DAACS-Nginx
    4 - DAACS-Backup 
    5 - DAACS-Memcached

Select instance type to create: " instance_type
read -p "Environment type (dev, qa, prod, etc, etc): " environment_type
read -p "Enter base path for install of DAACS env files (Leave blank to use default path): " install_env_path

if [ "$install_env_path" = "" ]; then
    install_env_path="$(get_absoluate_path_from_our_folder)/DAACS-Install-Defaults"
fi

case "$instance_type" in
"1") 


    # #check to see if nginx is running if not exit 0 because we need nginx to run 
    if  test $(docker ps --filter "name=nginx-proxy" | wc -l) -le 1 
    then
        echo "NGINX not running..."
    fi 

    create_web_instance_helper "$instance_type" "$install_env_path" "$environment_type"
    
    ;;
    *)
        echo "Invalid option"
    ;;
esac

exit 1