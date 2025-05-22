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
    string_val="$1"
    delimiter="$2"

    IFS="$delimiter" read -ra ADDR <<< "$string_val"
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
        "6-1") 
            echo "DAACS-Mongo/Instance"
        ;;
        "6-2") 
            echo "DAACS-Mongo/NewDB"
        ;;
        "6-3") 
            echo "DAACS-Mongo/Replica"
        ;;
        "7") 
            echo "DAACS-Webserver"
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

        read -p "Enter value for $i: " user_input
        unescape_backslash_new_env_equal=$(get_env_and_equal "$i")
        value1=$(get_reconfigure_env "$unescape_backslash_new_env_equal" "$i")
        value2=$(get_reconfigure_env "$unescape_backslash_new_env_equal" "$user_input")
        string_reaplce_in_file_expression="s/${value1}/${value2}/g"
        sed -i -E -e "$string_reaplce_in_file_expression" $input_file


    done
}

replace_env_variable_in_file(){

    i="$1"
    user_input="$2"
    input_file="$3"

    unescape_backslash_new_env_equal=$(get_env_and_equal "$i")
    value1=$(get_reconfigure_env "$unescape_backslash_new_env_equal" "$i")
    value2=$(get_reconfigure_env "$unescape_backslash_new_env_equal" "$user_input")
    string_reaplce_in_file_expression="s/${value1}/${value2}/g"
    sed -i -E -e "$string_reaplce_in_file_expression" $input_file
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

    echo $(echo "${1}" | sed -E -e 's/\+|\/|\*|\!|\@|\#|\$|\%|\|\*&|\(|\)|\_|\-|\=|\[|\]|\{|\}|\;|\’|\”|\,|\\<|\\>|\/|\?/\\&/g')
}

#Helper function to get env files based upon instance type
get_env_files_for_editing(){

    # 1 - DAACS-Website
    # 2 - DAACS-Qserver
    # 3 - DAACS-Nginx
    # 4 - DAACS-Backup 
    # 5 - DAACS-Memcached
    # 6 - DAACS-Mongo
    # 7 - DAACS-Webserver

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


refresh_all_services_in_service_helper(){

    root_dest="$1/new-env-setups"
    services_file_dir="$root_dest/$2/services"
    service_name="$3"
    count="$4"
    q_mode="$5"

    refresh_instance_helper "$root_dest" "$services_file_dir" "$service_name" "$count" "$q_mode"

}

#Get environment variable and value from env file
get_environment_value_from_file_by_env_name(){
    echo $(cat ${1} | grep "${2}")
}



# # new
write_service_subsititions_to_docker_file_new(){

    instance_type_defintion="${1}"
    install_folder_destination="${2}"
    install_env_path="${3}"
    environment_type_defintion="${4}"
    docker_changes_format="${5}"
    docker_file="${6}"
    

    create_director_if_it_does_exsist "$install_folder_destination/docker"

    # # copy docker file to new location to save for later use
    webserver_docker_file_from="$install_env_path/${instance_type_defintion}/docker/$docker_file"
    webserver_docker_file_to="${install_folder_destination}/docker/${docker_file}"

    cp "${webserver_docker_file_from}" "${webserver_docker_file_to}"
    
    sed  -i -e "${docker_changes_format}" "$webserver_docker_file_to"
    echo "$webserver_docker_file_to"
}

create_director_if_it_does_exsist(){

    new_dir_to_create="${1}"
    # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$folder_destination"
    if  ! $(test -d "${new_dir_to_create}") ;
    then
        mkdir -p "${new_dir_to_create}"
    fi
}

#Runs fill out env program for all env's
run_fillout_program_new(){

    env_list="${1}"    
    write_to_directory="${2}"    

    # Create env files for install
    IFS=' ' read -ra ADDR <<< "$env_list"
    for i in "${ADDR[@]}"; do
        filename=$(basename "$i")
        retval=$( fill_out_env_file "$i")
        write_env_to_file_new $retval $environment_type_defintion $write_to_directory $filename
    done

}


#Helper function to write env files to it's instance directory name in 
write_env_to_file_new(){
    
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

    if [ "$4" = "" ]; then
        echo "Missing file name"
        exit -1
    fi

    if  ! $(test -d "$3/$2") ;
    then
        mkdir -p "$3/$2"
    fi

    destdir="$3/$2/$filename"

    touch "$destdir"

    if [ -f "$destdir" ]
    then 
        printf "$1" > "$destdir"
    fi

}

# # Original
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

#Helper function to write env files to it's instance directory name in 
write_env_to_file(){
    
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

    if  ! $(test -d "$root_dest/$3/$e_type") ;
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


#Clones repo into destination folder
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


run_docker_with_envs(){

    webserver_docker_file_to="${1}"
    envs_for_docker_process="${2}"
    should_recreate="${3}"
    service_name=""
    sould_recreate_command_args=""
    envs_for_docker_processed=""

    if [ "$should_recreate" = true ]; then
        sould_recreate_command_args=" --force-recreate"
        service_name=" ${4}"
    fi    

    STRLENGTH=$(echo "${envs_for_docker_process}" | wc -m)

    if [ $STRLENGTH -gt 0 ]; then
        envs_for_docker_processed="${envs_for_docker_process} "
    fi

    # # run docker file
    catted="${envs_for_docker_processed} docker compose -f ${webserver_docker_file_to} up -d ${sould_recreate_command_args} ${service_name} "   
    eval "$catted"
}

get_services_ids_by_service_name(){
    service_name="$1"
    ids=$(docker ps --filter "label=com.docker.compose.service=$service_name" --format "{{.ID}}" | awk '{printf "%s ", $0}')
    echo "$ids"
}


add_services_service_file(){

    service_name="$1"
    me=$(get_services_ids_by_service_name "$service_name")
    service_name=$(echo $service_name | tr 'a-z' 'A-Z')
    service_entry="$service_name=$me"
    service_touch_file_dir="$2"

    touch "$service_touch_file_dir"

    echo "$service_entry" >> $service_touch_file_dir

}

update_services_ids_in_service_file(){
    file_dir="$1"
    readarray -t arr < $file_dir

    #loop through service file and get left hand side without equal and lowercase
    for i in "${arr[@]}"; do
        user_input=""
 
        unescape_backslash_new_env_equal=$(get_env_and_equal "$i")
        unescape_backslash_new_env_equal=${unescape_backslash_new_env_equal::-1}
        unescape_backslash_new_env_equal=$(echo $unescape_backslash_new_env_equal | tr 'A-Z' 'a-z')
        #get ids for each service and replace value
        ids=$(get_services_ids_by_service_name "$unescape_backslash_new_env_equal")
        #replace values in service file
        replace_env_variable_in_file "$i" "$ids" "$file_dir"
    done

}

restart_services_with_stagger_by_service_name(){
    service_name="$1"
    stagger_count="$2"
    ids=$(get_services_ids_by_service_name "$service_name")
    IFS=" " read -ra ADDR <<< "$ids"
    length=$(echo ${#ADDR[@]})
    reset_string=""
    quite_mode="${3}"
    quite_mode_command=""
    
    if [ "$quite_mode" == true ]; then        
        quite_mode_command=">/dev/null 2>&1"
    fi

    
    if [ $length -eq 0 ]; then
        printf "No services to restart...\n"
        return
    fi

    if [ $stagger_count -gt $length ]; then
        printf "Stagger cant be higher than amount of processess... setting to 1...\n"
        stagger_count=1
    fi
        
    if [ $length -eq 1 ]; then
        restart_server_string="docker restart ${ADDR[0]} $quite_mode_command"
            # echo "$restart_server_string"
            eval "$restart_server_string"

    else
        
        restart_server_string=""
        for ((i=0; i<$length; i+=$stagger_count))
        do
            server_list=""
            start_here=0
            
            if [ $stagger_count -gt 1 ]; then 
                start_here=$(( $i +  $stagger_count - 1  ))   

                for ((i2=$start_here ; i2>=$i; i2--))
                do
                    server_list="${ADDR[$i2]} $server_list"
                done
            else  
               
                server_list="$server_list ${ADDR[$i]}"
                
            fi
            if [ "$server_list" != "" ]; then
                restart_server_string="docker restart ${server_list} $quite_mode_command"
                # echo "$restart_server_string"
                eval "$restart_server_string"
            fi
        done
    fi
}

get_docker_service_count(){
    command_count=$(docker ps --filter "label=com.docker.compose.service=$service_name" | wc -l)
    command_count=$(($command_count - 1))
    echo "$command_count"
}

ask_read_question_or_try_again(){

    question_text="$1"
    try_again="$2"
 
    read -p "$question_text" service_name

    if [[ "$service_name" = ""  &&  $try_again == true ]]; then
        service_name=$(ask_read_question_or_try_again "$1"  "$try_again")
    fi

    echo $service_name

}


ask_for_docker_service_and_check(){

    question_text="$1"
    try_again=true
 
    service_name=$(ask_read_question_or_try_again "$question_text" "$try_again")

    service_count=$(get_docker_service_count "$service_name")
    
    if [ "$service_count" -gt 0  ]; then
        service_name=$(ask_for_docker_service_and_check "$1")
    fi 
    echo $service_name


}

does_dir_exsist(){

    update_dir="$1"
    if [ -d "$update_dir" ]; then
        echo true
    else
        echo false
    fi
}

refresh_instance_helper(){

    service_name="$3"
    s_file_dir="${2}"
    stagger_amount="$4"
    q_mode="$5"

    if [ "$stagger_amount" == "" ]; then 
        stagger_amount=1
    fi

    if [ "$q_mode" == "" ]; then 
        q_mode=false
    fi
    
    if [ "$service_name" != "" ]; then 
        
        entry=`cat $s_file_dir/$service_name`
        unescape_backslash_new_env_equal=$(get_env_and_equal "$entry")
        unescape_backslash_new_env_equal=${unescape_backslash_new_env_equal::-1}
        unescape_backslash_new_env_equal=$(echo $unescape_backslash_new_env_equal | tr 'A-Z' 'a-z')
        restart_services_with_stagger_by_service_name  "$unescape_backslash_new_env_equal" "$stagger_amount" "$q_mode"
        return
    fi

    for entry in "$s_file_dir"/*
    do
        
        readarray -t arr < $entry
        #loop through service file and get left hand side without equal and lowercase
        for i in "${arr[@]}"; do
            user_input=""
            unescape_backslash_new_env_equal=$(get_env_and_equal "$i")
            unescape_backslash_new_env_equal=${unescape_backslash_new_env_equal::-1}
            unescape_backslash_new_env_equal=$(echo $unescape_backslash_new_env_equal | tr 'A-Z' 'a-z')
            restart_services_with_stagger_by_service_name  "$unescape_backslash_new_env_equal"  "$stagger_amount" "$q_mode"
        done
    done
}


get_docker_file_by_enviroment_and_by_instsance_type(){

    instance_type="${1}"
    environment_type_defintion="${2}"
    docker_file=""

    case "$instance_type" in
        "1") 

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


        ;;

    esac

    echo "$docker_file"
}


get_web_server_env_values(){

    absolute_dir="${1}" 
    file_name="${2}" 
    local -n arr=$3
    env_file="${absolute_dir}${file_name}"

     declare -a env_array
    for i in "${arr[@]}"; do
        value=$(get_environment_value_from_file_by_env_name "${env_file}" "${i}")
        env_array+=("${value}")
    done
    echo "${env_array[@]}"
}

create_docker_services(){
    env_string="${1}"
    webserver_docker_file_to="${2}"
    force_recreate="${3}"
    service_name="${4}"
    
    run_docker_with_envs "$webserver_docker_file_to" "$env_string" "$force_recreate" "$service_name"
}


recreate_service(){

    base_path_folder_destination="${2}"
    install_folder_destination="${3}"
    instance_type="${4}"
    environment_type="${5}"
    service_name="${1}"

    force_recreate=true #only for recreate

    install_root=""
    install_env_path=""

    if [ "$install_env_path" = "" ]; then
        install_root=$current_dir
        install_env_path="$install_root/DAACS-Install-Defaults"
    fi

    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    docker_file=$(get_docker_file_by_enviroment_and_by_instsance_type "$instance_type" "$environment_type_defintion")

    web_env_array=("REPLICAS" "PORT")
    declare -a mong_env_array=("MONGODB_MAPPED_PORT" "MONGODB_CONTAINER_NAME")

    dest=( $(get_web_server_env_values "$absolute_dir" "webserver" web_env_array) $(get_web_server_env_values "$absolute_dir" "webserver-mongo" mong_env_array ) )

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"
    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${dest[1]} ${dest[0]} ${dest[3]} ${dest[2]}"


    webserver_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )
    create_docker_services "${env_string}" "${webserver_docker_file_to}" "${force_recreate}" "${service_name}"

}

does_service_exsist(){
    service_name="${1}"
    ids=$(get_services_ids_by_service_name "$service_name")
    IFS=" " read -ra ADDR <<< "$ids"
    length=$(echo ${#ADDR[@]})

    if [ $length -eq 0 ]; then
            echo false
        else
            echo true
    fi
}


does_docker_image_exsist(){

    
    if [ "$1" = "" ]; then
        echo "Missing docker image name."
        exit -1
    fi

    image_name="${1}"

    if [ -z "$(docker images -q ${image_name} 2> /dev/null)" ]; then
        echo false
    else
        echo true
    fi
}

get_system_archtechture(){

    echo $(lscpu | grep Architecture: | cut -f2 -d ":" | awk '{$1=$1};1')
}