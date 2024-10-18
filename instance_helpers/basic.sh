#!/bin/bash

get_absoluate_path_from_our_folder(){
    absolute_path=$(realpath ./)
    echo $absolute_path
}

#Helper function to check if the array is empty
is_array_empty() {
   arr=("$@")

    if [ ${#arr[@]} -eq 0 ]; then
        echo true
    else
        echo false
    fi

}

#Splits string value 
split_string_to_array(){
    IFS=' ' read -ra ADDR <<< "$1"
    echo "${ADDR[@]}"
}

#Gets env directory name baased upon environment 
get_env_type_definition(){

        case "$1" in
        
        "dev") 
            echo "env-dev"
        ;;

        "prod") 
            echo "env-prod"
        ;;

        *)
            exit -1
        ;;
    esac

}

#Gets instance directory name baased upon instance type 
get_instance_type_definition(){

    case "$1" in
        "1") 
            echo "DAACS-Website"
        ;;
        "2") 
            echo "DAACS-QServer"
        ;;
        "3") 
            echo "DAACS-Nginx"
        ;;
        "4") 
            echo "DAACS-Backup"
        ;;
        "5") 
            echo "DAACS-Memcached"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac
}

#Helper function to fill out env files
fill_out_env_file(){

    input_file=$1

    if [ "$input_file" = "" ]; 
    then
        echo "Input file source path is empty."
        exit 1
    fi

    readarray -t arr < $input_file

    are_we_empty=$(is_array_empty "${arr[@]}")

    if [ $are_we_empty == true ]; then
        echo "Missing variables in file"
        exit 1
    fi

    for i in "${arr[@]}"; do
        user_input=""
        read -p "Enter value for $i: " user_input
        file_output="$file_output$i$user_input\n" 
    done
    echo "$file_output"
}

#Helper function to get env files based upon instance type
get_env_files_for_editing(){

    # 1 - DAACS-Website
    # 2 - DAACS-Qserver
    # 3 - DAACS-Nginx
    # 4 - DAACS-Backup 
    # 5 - DAACS-Memcached

    instance_type=$(get_instance_type_definition "$1")
    environment_type=$(get_env_type_definition $3)
    search_dir="$2/$instance_type/$environment_type"

    declare -a arr

    for entry in "$search_dir"/*
    do
        arr=("${arr[@]}" "$entry")
    done

    echo "${arr[@]}"

}

#Helper function to write env files to it's instance directory name in 
write_env_to_file(){

    # root_dest=""
    root_dest="./new-env-setups"

    if [ "$1" = "" ]; then
        echo "Missing write data"
        exit -1
    fi

    if [ "$2" = "" ]; then
        echo "Missing environment type"
        exit -1
    fi
    
    if [ "$3" = "" ]; then
        echo "Missing folder name"
        exit -1
    fi

    environment_type=$2

    #if root_dest = "" then  EXIT -1

    if  ! $(test -d "$root_dest/$3/$environment_type") ;
    # if  ! (( $(test -d "$env_instance_path") )) ;
    then
        mkdir -p "$root_dest/$3/$environment_type"
    fi

    destdir="$root_dest/$3/$environment_type/$filename"
    touch "$destdir"

    if [ -f "$destdir" ]
    then 
        printf "$1" > "$destdir"
    fi

}

#Get environment variable and value from env file
get_environment_value_from_file_by_env_name(){
    echo $(cat ${1} | grep "${2}")
}

#Runs fill out env program for all env's
run_fillout_program(){

    # Create env files for install
    IFS=' ' read -ra ADDR <<< "$env_to_create"
    for i in "${ADDR[@]}"; do
        filename=$(basename "$i")
        retval=$( fill_out_env_file "$i")
        write_env_to_file $retval $environment_type_defintion $install_folder_destination $filename
    done
}

clone_repo(){
    
    base_path_folder_destination=$1
    install_folder_destination=$2
    repo=$3
    
    cd $base_path_folder_destination
    command="git clone ${repo} ${base_path_folder_destination}/${install_folder_destination}"
    eval "$command"
}

get_node_modules(){

    cd "${1}"
    npm ci 
}



write_service_subsititions_to_docker_file(){

    instance_type_defintion="${1}"
    install_folder_destination="${2}"
    install_env_path="${3}"
    environment_type_defintion="${4}"
    docker_changes_format="${5}"
    docker_file="${6}"
    
    # # copy docker file to new location to save for later use
    webserver_docker_file_from="$install_env_path/${instance_type_defintion}/docker/$docker_file"
    webserver_docker_file_to="${root_dest}/${install_folder_destination}/docker/${docker_file}"

    cp "${webserver_docker_file_from}" "${webserver_docker_file_to}"
    sed  -i -e "${docker_changes_format}" "$webserver_docker_file_to"
    echo "$webserver_docker_file_to"
}


run_docker_with_envs(){

    webserver_docker_file_to="${1}"
    envs_for_docker_process="${2}"

    # # run docker file
    catted="${envs_for_docker_process}"
    catted+=" docker compose -f ${webserver_docker_file_to} up -d"  
    eval "$catted"    
}
