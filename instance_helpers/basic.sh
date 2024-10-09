#!/bin/bash


is_array_empty() {
   arr=("$@")

    if [ ${#arr[@]} -eq 0 ]; then
        echo true
    else
        echo false
    fi

}

split_string_to_array(){
    # $input=$1
    IFS=' ' read -ra ADDR <<< "$1"
    echo "${ADDR[@]}"
}
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

get_instance_type_definition(){

    case "$1" in
        "1") 
            echo "DAACS-Website"
        ;;
        "2") 
            echo "DAACS-Qserver"
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
        # printf '%s\n' "$i$user_input"
        file_output="$file_output$i$user_input\n" 
    done
    echo "$file_output"
}


get_env_files_for_editing(){

    # 1 - DAACS-Website
    # 2 - DAACS-Qserver
    # 3 - DAACS-Nginx
    # 4 - DAACS-Backup 
    # 5 - DAACS-Memcached

    instance_type=$(get_instance_type_definition "$1")
    environment_type=""

    # case "$1" in
    #     "1") 
    #         instance_type="DAACS-Website"
    #     ;;
    #     "2") 
    #         instance_type="DAACS-Qserver"
    #     ;;
    #     "3") 
    #         instance_type="DAACS-Nginx"
    #     ;;
    #     "4") 
    #         instance_type="DAACS-Backup"
    #     ;;
    #     "5") 
    #         instance_type="DAACS-Memcached"
    #     ;;
    #     *)
    #         echo "Invalid instance option"
    #         exit -1
    #     ;;
    # esac

    environment_type=$(get_env_type_definition $3)
    search_dir="$2/$instance_type/$environment_type"

    declare -a arr

    for entry in "$search_dir"/*
    do
        arr=("${arr[@]}" "$entry")
    done

    echo "${arr[@]}"

}


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
