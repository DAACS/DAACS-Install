#!/bin/bash


# retval=$( fill_out_env_file "/root/DAACS-Install/DAACS-Website/env-dev/.env-dev-email")
# printf "$retval"
# exit 1
# #read file and print line by line
# readarray -t arr < /root/DAACS-Install/DAACS-Website/env-dev/.env-dev-email

#new-env-setups
# file_output=""
# for i in "${arr[@]}"; do
#     user_input=""
#     read -p "Enter value for ($i): " user_input
#     printf '%s\n' "$i$user_input"
#     file_output="$file_output$i$user_input\n" 
# done
# echo "FINAL"
# printf "$file_output"
# exit 1



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
read -p "Enter base path for install of DAACS (Leave blank to use default path): " install_env_path

  if [ "$install_env_path" = "" ]; then
        install_env_path="./DAACS-Install-Defaults"
    fi

case "$instance_type" in
   "1") 

   create_web_instance_helper "$instance_type" "$install_env_path" "$environment_type"
   ;;
    *)
        echo "Invalid option"
    ;;
esac


exit 1





# ------- everything below this won't be in the final script so move it out 

#write to file with variable
# destdir=/root/DAACS-setup-scripts/new-env-setups/woof
# touch $destdir

# if [ -f "$destdir" ]
# then 
#     echo "$var" > "$destdir"
# fi

# echo "woooff"

# exit 1

#read file and print line by line
readarray -t arr < /root/DAACS-Install/DAACS-Website/env-dev/.env-dev-email

#new-env-setups
for i in "${arr[@]}"; do
    user_input=""
    read -p "Enter value for ($i): " user_input
    printf '%s\n' "$i=$user_input"

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
