#!/bin/bash
source "$current_dir/instance_helpers/basic.sh"

: '
Instance types

    Mongo Single 
        (with or without SSL)
    Mongo Replica
        (with or without SSL)
        Init Replica set
        Add Replica
        Remove Replica

Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'


MONGO_REPLICA_IMAGE_NAME="mongo-replica"
MONGO_IMAGE_NAME="daacs-mongo"
MY_DOCKER_NETWORK_NAME="myNetwork"

mongo_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nMongo server instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    new_or_update=$(ask_read_question_or_try_again "(n)ew or (u)pdate (r)eplica (c)reate database (i)nitialize replica set (a)dd to replica set  : " true)
    
    case "$new_or_update" in

    "n") 
        
        create_mongo_instance_helper
    ;;


    "c")


        mongo_service=$(ask_read_question_or_try_again "What mongo container name?: " true)
        environment_type_defintion=$(get_env_type_definition "$environment_type")
        root_dest="$install_root/new-env-setups"
        
        add_mongo_database_to_instance "$mongo_service" "$root_dest/$install_folder_destination/" "$environment_type_defintion-"

    ;;
    
    "rr")
        remove_mongo_process_from_replica_set
    ;;

    "r") 
        
        create_replica_mongo_instance_helper
    ;;

    "i")
        init_replica_mongo_instance_helper
    ;;

    "a")
        add_replica_mongo_instance_helper
    ;;
    "crf")
        #create replica files
        #  mongo_folder=$(ask_read_question_or_try_again "Enter folder to save mongo replica services for install of DAACS: " true)
        #   create_mongo_replica_connection_files "$environment_type" "$mongo_folder"

    ;;

    "crf")
        #create replica files
        #  mongo_folder=$(ask_read_question_or_try_again "Enter folder to save mongo replica services for install of DAACS: " true)
        # create_database_files "$mongo_database_directory" "$mongo_folder"


    ;;
    "u") 

        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_env == true ]]; then
            update_mongo_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi

    ;;
    
    
    *)
        echo "Invalid option"
    ;;
    esac
}


create_mongo_instance_helper(){

    instance_type="6-1"
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    qserver_files_to="$install_env_path/$instance_type_defintion/docker/Dockerfile-webserver-mongo-dev"
    create_image "$qserver_files_to" "${MONGO_IMAGE_NAME}" "$install_env_path/$instance_type_defintion/docker/" 
 
    printf "\nCREATING Mongo server instance....\n"

    mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " true)
    copy_ssl_cert_from_container=$(ask_for_docker_service_and_check "Copy SSL cert from container? : " true)
    do_create_database=$(ask_read_question_or_try_again "Do you want to create database for web server? : " true)
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    mongo_docker_directory="$root_dest/$install_folder_destination/docker/"

    # Create env files for install
    run_fillout_program "$env_to_create"
    create_directory_if_it_does_exsist "$mongo_docker_directory"

    env_webserver_mongo_file="${absolute_dir}webserver-mongo"
    docker_file=$(get_mongo_docker_filename "$environment_type_defintion")

    qserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#mongo_service_name/$mongo_service_name/g ;" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    #build file
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/Dockerfile-webserver-mongo-dev"
    qserver_files_to="$mongo_docker_directory/Dockerfile-webserver-mongo-dev"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    #mongo conf file
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/mongod.conf"
    qserver_files_to="$mongo_docker_directory/mongod.conf"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    #run script
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/run.sh"
    qserver_files_to="$mongo_docker_directory/run.sh"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")

    # Checks to see if port is being used by something else and ask for a different port
    check_if_port_is_being_used $(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT") "$env_webserver_mongo_file" "mongo"

    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${mongo_container_name} ${mongo_port} ${qserver_container_name}"
    
    run_docker_with_envs "$qserver_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    create_directory_if_it_does_exsist "$services_file_dir"

    add_services_service_file "$mongo_service_name" "$services_file_dir/$mongo_service_name"

    if [ "$copy_ssl_cert_from_container" = "true" ]; then
        copy_ssl_from_container "$root_dest/$mongo_service_name/ssl/" "$mongo_service_name" "$mongo_id"
    fi
    
    #add database to primary on creation
    if [ "$do_create_database" = "true" ]; then
        mongo_container_val=$(get_env_value "${mongo_container_name}")  
        add_mongo_database_to_instance "$mongo_container_val" "$root_dest/$install_folder_destination/" "$environment_type_defintion-"
    fi

}

#Be nice to initaliza replica all in one function but i need to figure out how to wait and see if mongo process is ready
#Must use same install folder if want to loop on webserver creation
create_replica_mongo_instance_helper(){

    instance_type="6-3"
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    is_this_init_process=$(ask_read_question_or_try_again "Is this process the first one? (Init replica process) : " true)
    copy_ssl_cert_from_container=$(ask_for_docker_service_and_check "Copy SSL cert from container? : " true)
    do_create_database=$(ask_read_question_or_try_again "Do you want to create database for web server? : " true)
    
    create_image "$install_env_path/${instance_type_defintion}/docker/Dockerfile-webserver-mongo-dev" "${MONGO_REPLICA_IMAGE_NAME}" "$install_env_path/${instance_type_defintion}/docker/" "file_dir=$install_env_path/${instance_type_defintion}/docker/"

    printf "\nCREATING Replica mongo server instance....\n"

    mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " )
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"


    instance_home_folder="$root_dest/$install_folder_destination/docker/${mongo_service_name}"
    create_directory_if_it_does_exsist "$instance_home_folder"
    
    # Create env files for install
    run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type"

    primary_mongo_service_name=""
    if [ "$is_this_init_process" = "true" ]; then
        primary_mongo_service_name=$(ask_read_question_or_try_again "Primary host : " true)
        
    fi

    env_dir="$instance_home_folder/$environment_type_defintion/$environment_type_defintion-"

    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${env_dir}webserver-mongo"

    check_if_port_is_being_used $(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT") "$env_webserver_mongo_file" "mongo"


    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    host_or_ip=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_HOST_OR_IP")
    replica_set_id=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_REPLICA_SET_ID")

    docker_file=""
 
    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Replica-Mongo-dev.docker.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Replica-Mongo-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    qserver_docker_file_to=$(write_service_subsititions_to_docker_file_new "$instance_type_defintion" "$instance_home_folder" "$install_env_path" "$environment_type_defintion" "s/#mongo_service_name/$mongo_service_name/g ;" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$env_dir"

    #build file
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/Dockerfile-webserver-mongo-dev"
    qserver_files_to="${instance_home_folder}/docker/Dockerfile-webserver-mongo-dev"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    #mongo conf file
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/mongod.conf"
    qserver_files_to="${instance_home_folder}/docker/mongod.conf"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    #run script
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/run.sh"
    qserver_files_to="${instance_home_folder}/docker/run.sh"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${mongo_container_name} ${mongo_port} ${qserver_container_name} ${replica_set_id}"

    run_docker_with_envs "$qserver_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"

    add_services_service_file "$mongo_service_name" "$services_file_dir/$mongo_service_name"
    mongo_container_val=$(get_env_value "${mongo_container_name}")  
    mongo_port_val=$(get_env_value "${mongo_port}")  
    replica_set_id_val=$(get_env_value "${replica_set_id}")
    host_or_ip_val=$(get_env_value "${host_or_ip}")  

    if [ "$is_this_init_process" = "true" ]; then
        
        #add database to primary on creation
        if [ "$do_create_database" = "true" ]; then
            add_mongo_database_to_instance "$mongo_container_val" "$root_dest/$install_folder_destination/" "$environment_type_defintion-"
        fi

        initiate_mongo_process_to_replica_set "$mongo_container_val" "$replica_set_id_val" "1" "$mongo_port_val" "$host_or_ip_val" 

    else
        add_mongo_process_to_replica_set "$primary_mongo_service_name" "$host_or_ip_val:$mongo_port_val"

    fi 

    if [ "$copy_ssl_cert_from_container" = "true" ]; then
        copy_ssl_from_container "$root_dest/$mongo_service_name/ssl/" "$mongo_service_name" "$mongo_id"
    fi
    
}

#Be nice to initaliza replica all in one function but i need to figure out how to wait and see if mongo process is ready
add_replica_mongo_instance_helper(){

    instance_type="6-3"
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    replica_set_id=$(ask_read_question_or_try_again "Replica set ID : " true)
    hostname=$(ask_read_question_or_try_again "Mongo DNS hostname? : ")
    
    printf "\nAdding Replica mongo server instance....\n"

    primary_mongo_service_name=$(ask_read_question_or_try_again "Primary mongo service name : " true) #the primary mongo
    mongo_service_name=$(ask_read_question_or_try_again "Enter name for mongo service to add to replica: " ) #the secondary mongo
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"

    instance_home_folder="$root_dest/$install_folder_destination/docker/${mongo_service_name}"
    env_dir="$instance_home_folder/$environment_type_defintion/$environment_type_defintion-"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${env_dir}webserver-mongo"
    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    mongo_container_val=$(get_env_value "${mongo_container_name}")  
    mongo_port_val=$(get_env_value "${mongo_port}")  
    
    if [ -z $hostname ]; then
        hostname=$(get_current_server_ip)
    fi 

    primary_instance_home_folder="$root_dest/$install_folder_destination/docker/${primary_mongo_service_name}"
    env_dir="$primary_instance_home_folder/$environment_type_defintion/$environment_type_defintion-"
    env_webserver_mongo_file="${env_dir}webserver-mongo"
    primary_mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    primary_mongo_container_name=$(get_env_value "${primary_mongo_container_name}")  

    add_mongo_process_to_replica_set "$primary_mongo_container_name" "$hostname:$mongo_port_val"

}


init_replica_mongo_instance_helper(){

    instance_type="6-3"
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    is_this_init_process="true"

    printf "\nINIT Replica mongo server instance....\n"

    mongo_service_name=$(ask_read_question_or_try_again "Enter name for mongo service : " true)
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"

    instance_home_folder="$root_dest/$install_folder_destination/docker/${mongo_service_name}"
    env_dir="$instance_home_folder/$environment_type_defintion/$environment_type_defintion-"

    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${env_dir}webserver-mongo"

    host_or_ip=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_HOST_OR_IP")
    replica_set_id=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_REPLICA_SET_ID")
    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")

    if [ "$is_this_init_process" = "true" ]; then
        
        mongo_container_val=$(get_env_value "${mongo_container_name}")  
        mongo_port_val=$(get_env_value "${mongo_port}")  
        replica_set_id_val=$(get_env_value "${replica_set_id}"
        host_or_ip_val=$(get_env_value "${host_or_ip}")  
        )  
        initiate_mongo_process_to_replica_set "$mongo_container_val" "$replica_set_id_val" "1" "$mongo_port_val" "$host_or_ip_val" 

    fi 
    
}

copy_ssl_from_container(){
    
    input_1="${1}"
    input_2="${2}"
    input_3="${3}"

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$mongo_service_name/ssl" - but it should already exsist
    if  ! $(test -d "$input_1") ;
    then
        mkdir -p "$input_1"
    fi
    
    input_3=$(get_services_ids_by_service_name "$input_2")
    input_3=$(echo "$input_3" | tr -d " " )
    command="docker cp ${input_3}:/home/mongossl.pem ${input_1}mongossl.pem"
    eval "$command"
}

add_mongo_database_to_instance(){

    mongo_service=""
    mong_env_file_dir=""
    should_save_envs_files=true

    if [ $(is_string_length_greater_than_specified "${1}" 0) = true ]; 
        then
        mongo_service="${1}"
    else
        mongo_service=$(ask_read_question_or_try_again "What mongo service name?: " true)
    fi

    MONGODB_DATABASE_NAME=$(ask_read_question_or_try_again "Database name: " true)
    MONGO_USERNAME=$(ask_read_question_or_try_again "Username: " true)
    MONGO_PASSWORD=$(ask_read_question_or_try_again "Password: " true)
    API_CLIENT_ID=$(ask_read_question_or_try_again "API Client ID: " true)
    WEB_SERVER_COMMUNICATION_USERNAME=$(ask_read_question_or_try_again "Web server communication username: " true)
    WEB_SERVER_COMMUNICATION_PASSWORD=$(ask_read_question_or_try_again "Web server communication password: " true)
    WEB_SERVER_COMMUNICATION_EMAIL=$(ask_read_question_or_try_again "Web server communication email: " true)
    WEB_SERVER_ADMIN_USERNAME=$(ask_read_question_or_try_again "Web server admin username: " true)
    WEB_SERVER_ADMIN_PASSWORD=$(ask_read_question_or_try_again "Web server admin password: " true)
    WEB_SERVER_ADMIN_EMAIL=$(ask_read_question_or_try_again "Web server admin email: " true)


    if [ $(is_string_length_greater_than_specified "${2}" 0) = true ]; then

        mongo_service_install_dir="${2}/databases"
        create_directory_if_it_does_exsist "$mongo_service_install_dir"
        mong_env_file_dir="${mongo_service_install_dir}/${MONGODB_DATABASE_NAME}/"
        
    fi

    mongo_stuff="MONGODB_DATABASE_NAME=${MONGODB_DATABASE_NAME}\nMONGO_USERNAME=${MONGO_USERNAME}\nMONGO_PASSWORD=${MONGO_PASSWORD}\nMONGODB_CONTAINER_NAME=${mongo_service}\n"

    if [ "$should_save_envs_files" = true ]; then
        webserver_mongo="$mong_env_file_dir/webserver-mongo"
        create_directory_if_it_does_exsist "${mong_env_file_dir}"
        touch "$webserver_mongo"
        printf "$mongo_stuff" > "$webserver_mongo"

    fi

 
    webserver_stuff="API_CLIENT_ID=${API_CLIENT_ID}\nWEB_SERVER_COMMUNICATION_PASSWORD=${WEB_SERVER_COMMUNICATION_PASSWORD}\nWEB_SERVER_COMMUNICATION_USERNAME=${WEB_SERVER_COMMUNICATION_USERNAME}\nWEB_SERVER_COMMUNICATION_EMAIL=${WEB_SERVER_COMMUNICATION_EMAIL}\nWEB_SERVER_ADMIN_PASSWORD=${WEB_SERVER_ADMIN_PASSWORD}\nWEB_SERVER_ADMIN_USERNAME=${WEB_SERVER_ADMIN_USERNAME}\nWEB_SERVER_ADMIN_EMAIL=${WEB_SERVER_ADMIN_EMAIL}"

    if [ "$should_save_envs_files" = true ]; then
        webserver_mongo="$mong_env_file_dir/oauth"
        touch "$webserver_mongo"
        printf "$webserver_stuff" > "$webserver_mongo"
    fi 

    #create /dbs/$mongo_folder_filename
    command="docker exec -it ${mongo_service} sh -c \"export MONGODB_DATABASE_NAME=${MONGODB_DATABASE_NAME} MONGO_USERNAME=${MONGO_USERNAME} MONGO_PASSWORD=${MONGO_PASSWORD} API_CLIENT_ID=${API_CLIENT_ID} WEB_SERVER_COMMUNICATION_PASSWORD=${WEB_SERVER_COMMUNICATION_PASSWORD} WEB_SERVER_COMMUNICATION_USERNAME=${WEB_SERVER_COMMUNICATION_USERNAME} WEB_SERVER_COMMUNICATION_EMAIL=${WEB_SERVER_COMMUNICATION_EMAIL} WEB_SERVER_ADMIN_PASSWORD=${WEB_SERVER_ADMIN_PASSWORD} WEB_SERVER_ADMIN_USERNAME=${WEB_SERVER_ADMIN_USERNAME} WEB_SERVER_ADMIN_EMAIL=${WEB_SERVER_ADMIN_EMAIL} && mongosh --quiet  < /docker-entrypoint-initdb.d/mongo-init.js \" > /dev/null"

    eval "$command"

    pretty_print "${Color_Off}${Green}${MONGODB_DATABASE_NAME}${Color_Off} database added to ${Red}${mongo_service}${Color_Off}."
    
}

update_mongo_instance_helper(){
    printf "\nUPDATING Mongo DB instance....\n"
    instance_type="6-1"

    should_update_envs=$(ask_read_question_or_try_again "Should I update envs? (y)es or (n)o: " true)
  
    # #Check to see if package.json or package.json.lock file has changed to redownload node_modules -todo
    root_dest="$install_root/new-env-setups"
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")

    # # build frontend
    env_to_create=$(get_env_files_for_updating "$root_dest/$install_folder_destination" $environment_type)

    if [ "$should_update_envs" = "y" ]; then
        # Update env files for updating service
        run_fillout_program_for_update "$env_to_create"
    fi

    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    env_webserver_mongo_file="${absolute_dir}webserver-mongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    docker_file=$(get_mongo_docker_filename "$environment_type_defintion")
    qserver_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )
    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"
    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"
    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"
    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${mongo_container_name} ${mongo_port} "

    run_docker_with_envs "$qserver_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done

}

create_mongo_image(){

    if [ $(does_docker_image_exsist "${2}") == false ]; then
        printf "\nCreating mongo replica image exsist....\n"

        build_args=$(echo "${3}" | wc -m)

        if [ $(echo "${3}" | wc -m) -gt 0 ]; then
            build_args="--build-arg ${3}"
        fi
        
        command="cd ${4} && docker build ${build_args} -t ${2} -f ${1} ."
        eval "$command"
    fi

}

initiate_mongo_process_to_replica_set(){

    primary_mongo_service_name="${1}"
    replica_set_id="${2}"
    priority="${3}"
    port="${4}"
    hostname="${5}"

    if [ -z $hostname ]; then
        hostname=$(get_current_server_ip)
    fi 

    if [ -z $priority ]; then
        priority="1"
    fi 

    config="rs.initiate({ '_id' : '${replica_set_id}', 'members':[ { '_id' : 0, 'host' : '${hostname}:${port}', priority: ${priority} } ] });"
    
    command="docker exec -it ${primary_mongo_service_name} mongosh --eval \"${config}\""
    eval "$command"

}

add_mongo_process_to_replica_set(){

    primary_mongo_service_name="${1}"
    new_mongo_service_name="${2}"
    command="docker exec -it ${primary_mongo_service_name} mongosh --eval \"rs.add({host: '${new_mongo_service_name}' })\" "
    eval "$command"
}


remove_mongo_process_from_replica_set(){

    primary_mongo_service_name="${1}"
    new_mongo_service_name="${2}"
    command="docker exec -it ${primary_mongo_service_name} mongosh --eval \"rs.remove({host: '${new_mongo_service_name}' })\" "
    eval "$command"
}

#todo - it works but I need to add this to command so I can add after replica init
add_my_own_admin_account_to_docker_mongo(){

    primary_mongo_service_name="${1}"
    username="${2}"
    password="${3}"

    command=" docker exec -it ${primary_mongo_service_name} mongosh  --eval \"db.getSiblingDB('admin').createUser({ user: '${username}', pwd: '${password}', roles:['root']})\"; " 

# echo "$command"
    eval "$command"
   
#    docker exec -it loadmongo mongosh bash
#     use admin
#     db.createUser(
#     {
#         user: "tom", 
#         pwd: "jerry", 
#         roles:["root"]
#     })

    

}

#todo 
get_mongo_replica_status(){

    primary_mongo_service_name="${1}"
    status=$(docker exec -it ${primary_mongo_service_name} mongosh --eval "rs.status()")

    echo "$status"
}

#not used but keep it 
# copy_file_into_container(){
#     container_id="${1}"
#     file="${2}"
#     location="${3}"
#     command="docker cp ${file} ${container_id}:${location}"
#     eval "$command"
# }


get_mongo_docker_filename(){
    return_file=""
    case "$environment_type_defintion" in
    "env-dev") 
        return_file="Docker-Webserver-Mongo-dev.docker.yml"
    ;;
    "env-prod") 
        return_file="Docker-Webserver-Mongo-prod.docker.yml"
    ;;
    *)
        echo "Invalid instance option"
        exit -1
    ;;
    esac
    echo "$return_file"
}


