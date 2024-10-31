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

#Helper function to fill out env files
fill_out_env_file_for_updating(){

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

        #OLD WAY
        # read -p "Enter value for $i: " user_input
        # i_escaped=$(escape_backslash "${i}")
        # user_input_escaped=$(escape_backslash "${user_input}")
        # expression="s/=[^][\w+]*/=${user_input_escaped}/g"
        # new_new=$(echo $i | sed -E "${expression}")
        # new_new_escaped=$(escape_backslash "${new_new}")
        # string_reaplce_in_file_expression="s/${i_escaped}/${new_new_escaped}/g"
        # sed -i -E "$string_reaplce_in_file_expression" $input_file

        #NEW WAY 

        read -p "Enter value for $i: " user_input
        unescape_backslash_new_env_equal=$(get_env_and_equal "$i")
        value1=$(get_reconfigure_env "$unescape_backslash_new_env_equal" "$i")
        value2=$(get_reconfigure_env "$unescape_backslash_new_env_equal" "$user_input")
        string_reaplce_in_file_expression="s/${value1}/${value2}/g"
        sed -i -E -e "$string_reaplce_in_file_expression" $input_file


    done
}

get_env_and_equal(){
    value=$1
    expression='s/=(.*\n(\?=[A-Z])|.*$)/=/g'
    new_env_equal=$(echo $value | sed -E -e "${expression}")
    unescape_backslash_new_env_equal=$(unescape_backslash "$new_env_equal")
    echo "$unescape_backslash_new_env_equal"
}


get_env_value(){

    value=$1
    i_escaped=$(escape_backslash "${value}")
    expression="s/[^][\w+]*=//g"
    new_new=$(echo $value | sed -E "${expression}")
    echo "$new_new"
}


get_reconfigure_env(){
    beginning_env=$1
    end_env=$2
    end_env=$(get_env_value "$end_env")
    end_env=$(escape_backslash "$end_env")
    echo "$beginning_env$end_env"

}

unescape_backslash(){
    echo $(echo "${1}" | sed -E -e 's/\\//g')

}

escape_backslash(){

    # echo $(echo "${1}" | sed 's/\//\\\//g')
    # echo $(echo "${1}" | sed -e "s/'/'\\\\''/g; 1s/^/'/; \$s/\$/'/")
    # echo $(echo "${1}" | sed -e 's/[[:alpha:]]/\\&/g')
    # echo  "$1"

    echo $(echo "${1}" | sed -E -e 's/\+|\/|\*|\!|\@|\#|\$|\%|\|\*&|\(|\)|\_|\-|\=|\[|\]|\{|\}|\;|\’|\”|\,|\\<|\\>|\/|\?/\\&/g')
}

# |\<|\>|\/|\?


    # # echo $(echo "${1}" | sed 's/\//\\\//g')
    # echo $(echo "${1}" | sed -e 's/./\\&/g; 1{$s/^$/""/}; 1!s/^/"/; $!s/$/"/')
    # # echo $(echo "${1}" | sed -e " s/\[^\\w\]/ ")
    # # echo $(echo "${1}" | sed -e 's/[[:alpha:]]/\\&/g')
    # # echo $(echo "${1}" | sed -e "s/!\"\#\$\%\&\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\{\|\}\~./\\&/g")



#Helper function to get env files based upon instance type
get_env_files_for_editing(){

    # 1 - DAACS-Website
    # 2 - DAACS-Qserver
    # 3 - DAACS-Nginx
    # 4 - DAACS-Backup 
    # 5 - DAACS-Memcached

    instance_type=$(get_instance_type_definition "$1")
    e_type=$(get_env_type_definition "$3")
    search_dir="$2/$instance_type/$e_type"

    declare -a arr

    for entry in "$search_dir"/*
    do
        arr=("${arr[@]}" "$entry")
    done

    echo "${arr[@]}"

}

get_env_files_for_updating(){

    e_type=$(get_env_type_definition $2)
    search_dir=""

    search_dir="$1/$e_type"

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

    e_type=$2

    #if root_dest = "" then  EXIT -1

    if  ! $(test -d "$root_dest/$3/$e_type") ;
    # if  ! (( $(test -d "$env_instance_path") )) ;
    then
        mkdir -p "$root_dest/$3/$e_type"
    fi

    destdir="$root_dest/$3/$e_type/$filename"
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


#Runs fill out env program for all env's
run_fillout_program_for_update(){

    # Create env files for install
    IFS=' ' read -ra ADDR <<< "$env_to_create"
    for i in "${ADDR[@]}"; do
        filename=$(basename "$i")
        echo "$filename"
        read -p "Do we want to update ${filename} ? (y)es or (n)o : " should_update_file

        if [ "$should_update_file" == "y" ]; then
            fill_out_env_file_for_updating "$i"
        fi
    done
}


#Clones repo into destination folder - todo need to check if dir is empty and ask to clear it if it isn't
clone_repo(){
    
    base_path_folder_destination=$1
    install_folder_destination=$2
    repo=$3
    
    mkdir -p "${base_path_folder_destination}/${install_folder_destination}"

    cd $base_path_folder_destination
    command="git clone ${repo} ${base_path_folder_destination}/${install_folder_destination}"
    eval "$command"
}

get_repo_latest(){

    base_path_folder_destination=$1
    install_folder_destination=$2
    
    command="cd $base_path_folder_destination/$install_folder_destination &&  git pull"
    eval "$command"

}

get_node_modules(){

    cd "${1}"
    npm ci 
}



generate_docker_file_path(){

    to_or_from="${1}"
    install_folder_destination="${2}"
    docker_file="${3}"
    install_env_path="${4}"
    instance_type_defintion="${5}"

    return_string=""

    if [ "$to_or_from" == "to" ]; then
        return_string="${root_dest}/${install_folder_destination}/docker/${docker_file}"
    fi

    if [ "$to_or_from" == "from" ]; then
        return_string="$install_env_path/${instance_type_defintion}/docker/$docker_file"
    fi

    echo "$return_string"
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
    output=$(eval "$catted")

}
