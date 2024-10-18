#!/bin/bash

# ./DAACS-Install-Defaults - folder for default .env files
. ./instance_helpers/web.sh
. ./instance_helpers/qserver.sh
. ./instance_helpers/nginx.sh
. ./instance_helpers/backup.sh

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

install_root=""

if [ "$install_env_path" = "" ]; then
    install_root=$(get_absoluate_path_from_our_folder)
    install_env_path="$install_root/DAACS-Install-Defaults"
fi

case "$instance_type" in
"1") 


    # #check to see if nginx is running if not exit 0 because we need nginx to run 
    if  test $(docker ps --filter "name=nginx-proxy" | wc -l) -le 1 
    then
        echo "NGINX not running..."
    fi 

    create_web_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;

"2") 

    create_qserver_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;


"3") 

    create_nginx_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;


"4") 

    create_backup_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;


"5") 

    create_memcached_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;

*)
    echo "Invalid option"
;;
esac
