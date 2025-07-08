#!/bin/bash

# ./DAACS-Install-Defaults - folder for default .env files
source "$current_dir/instance_helpers/web.sh"
source "$current_dir/instance_helpers/webserver.sh"
source "$current_dir/instance_helpers/mongo.sh"
source "$current_dir/instance_helpers/qserver.sh"
source "$current_dir/instance_helpers/nginx.sh"
source "$current_dir/instance_helpers/backup.sh"
source "$current_dir/instance_helpers/basic.sh"

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
Pick instance type to create

    1 - DAACS-Website
    2 - DAACS-Qserver
    3 - DAACS-Nginx
    4 - DAACS-Backup 
    5 - DAACS-Memcached
    6 - DAACS-Mongo
    7 - Create MongoDB 

Select instance type to create: " instance_type
environment_type=$(ask_read_question_or_try_again "Environment type (dev, qa, prod, etc, etc): " true)
install_env_path=$(ask_read_question_or_try_again "Enter base path for install of DAACS env files (Leave blank to use default path): " false)

install_root=""

if [ "$install_env_path" = "" ]; then
    install_root=$current_dir
    install_env_path="$install_root/DAACS-Install-Defaults"
fi

case "$instance_type" in
"1") 


    # #check to see if nginx is running if not exit 0 because we need nginx to run 
    if  test $(docker ps --filter "name=nginx-proxy" | wc -l) -le 1 
    then
        echo "NGINX not running..."
    fi 

    web_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;

"2") 

    qserver_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;


"3") 

    create_nginx_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;


"4") 

    backup_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"

;;


"5") 

    create_memcached_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"
;;

"6") 

    mongo_instance_helper "$instance_type" "$install_env_path" "$environment_type" "$install_root"
;;

"7")
    
    add_mongo_database_to_instance 

;;

*)
    echo "Invalid option"
;;
esac

