#!/bin/bash
source "$current_dir/instance_helpers/basic.sh"

: '
Instance types

    Mongo Single 
        (with or without SSL)
    Mongo Replica
        (with or without SSL)

Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'

mongo_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nMongo server instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    new_or_update=$(ask_read_question_or_try_again "(n)ew or (u)pdate (r)eplica (c)reate database : " true)
    
    case "$new_or_update" in
    "r") 
        
        create_replica_mongo_instance_helper
    ;;

    "n") 
        
        create_mongo_instance_helper
    ;;

    "u") 

        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        # echo "$base_path_folder_destination/$install_folder_destination"
        echo "$install_root/new-env-setups/$install_folder_destination"

        if [[ $does_dir_env == true ]]; then
            update_mongo_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi

    ;;
    

    "c")

        add_mongo_database_to_instance

    ;;
    
    *)
        echo "Invalid option"
    ;;
    esac
}


create_mongo_instance_helper(){

    printf "\nCREATING Mongo server instance....\n"

    instance_type="6-1"

    mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " true)
    copy_ssl_cert_from_container=$(ask_for_docker_service_and_check "Copy SSL cert from container? : " true)
    do_create_database=$(ask_read_question_or_try_again "Do you want to create database for web server?" true)
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    root_dest="$install_root/new-env-setups"

    # Create env files for install
    run_fillout_program "$env_to_create"

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$foldername"
    if  ! $(test -d "$root_dest/$install_folder_destination/docker/") ;
    then
        mkdir -p "$root_dest/$install_folder_destination/docker/"
    fi

    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")

    docker_file=""
 
    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Webserver-Mongo-dev.docker.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Webserver-Mongo-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    qserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#mongo_service_name/$mongo_service_name/g ;" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    #build file
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/Dockerfile-webserver-mongo-dev"
    qserver_files_to="${root_dest}/${mongo_service_name}/docker/Dockerfile-webserver-mongo-dev"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    #mongo conf file
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/mongod.conf"
    qserver_files_to="${root_dest}/${mongo_service_name}/docker/mongod.conf"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    #run script
    qserver_files_from="$install_env_path/${instance_type_defintion}/docker/run.sh"
    qserver_files_to="${root_dest}/${mongo_service_name}/docker/run.sh"
    cp "${qserver_files_from}" "${qserver_files_to}"
    
    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${mongo_container_name} ${mongo_port} ${qserver_container_name}"
    
    run_docker_with_envs "$qserver_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"

    add_services_service_file "$mongo_service_name" "$services_file_dir/$mongo_service_name"

    if [ "$copy_ssl_cert_from_container" = "true" ]; then
        copy_ssl_from_container "$root_dest/$mongo_service_name/ssl/" "$mongo_service_name" "$mongo_id"
    fi
    
    #add database to primary on creation
    if [ -z "$do_create_database" ]; then
        add_mongo_database_to_instance
    fi


}

create_replica_mongo_instance_helper(){

    instance_type="6-3"
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    is_this_init_process=$(ask_read_question_or_try_again "Is this process the first one? (Init replica process)" true)
    copy_ssl_cert_from_container=$(ask_for_docker_service_and_check "Copy SSL cert from container? : " true)
    do_create_database=$(ask_read_question_or_try_again "Do you want to create database for web server?" true)
    replica_set_id=$(ask_read_question_or_try_again "Replica set ID" true)
    
    create_image "$install_env_path/${instance_type_defintion}/docker/Dockerfile-webserver-mongo-dev" "${MONGO_REPLICA_IMAGE_NAME}" "$install_env_path/${instance_type_defintion}/docker/" "file_dir=$install_env_path/${instance_type_defintion}/docker/"

    printf "\nCREATING Replica mongo server instance....\n"

    mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " )
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"

    instance_home_folder="$root_dest/$install_folder_destination/docker/${mongo_service_name}"
    create_director_if_it_does_exsist "$instance_home_folder"
    
    # Create env files for install
    run_fillout_program_new "$env_to_create" "$instance_home_folder"

    env_dir="$instance_home_folder/$environment_type_defintion/$environment_type_defintion-"

    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${env_dir}webserver-mongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")

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

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${mongo_container_name} ${mongo_port} ${qserver_container_name}"

    run_docker_with_envs "$qserver_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"

    add_services_service_file "$mongo_service_name" "$services_file_dir/$mongo_service_name"

    if [ -z "$is_this_init_process" ]; then

        hostname="${3}"
        port="${4}"
        priority="${5}"

        #add database to primary on creation
        if [ -z "$do_create_database" ]; then
            add_mongo_database_to_instance
        fi

        initiate_mongo_process_to_replica_set "$mongo_service_name" "$replica_set_id" "$hostname" "$port" "$priority"

    else

        primary_mongo_service_name="${1}"
        new_mongo_service_name="${2}"
        add_mongo_process_to_replica_set "$primary_mongo_service_name" "$new_mongo_service_name"

    fi 

    if [ "$copy_ssl_cert_from_container" = "true" ]; then
        copy_ssl_from_container "$root_dest/$mongo_service_name/ssl/" "$mongo_service_name" "$mongo_id"
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
#todo - to replace create_mongo_database_helper function, or we could ask for files and if wasn't supplied then manual fill in envs
add_mongo_database_to_instance(){

    mongo_service=$(ask_read_question_or_try_again "What mongo service name?: " true)
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

    #create /dbs/$mongo_folder_filename
    command="docker exec -it ${mongo_service} sh -c \"export MONGODB_DATABASE_NAME=${MONGODB_DATABASE_NAME} MONGO_USERNAME=${MONGO_USERNAME} MONGO_PASSWORD=${MONGO_PASSWORD} API_CLIENT_ID=${API_CLIENT_ID} WEB_SERVER_COMMUNICATION_PASSWORD=${WEB_SERVER_COMMUNICATION_PASSWORD} WEB_SERVER_COMMUNICATION_USERNAME=${WEB_SERVER_COMMUNICATION_USERNAME} WEB_SERVER_COMMUNICATION_EMAIL=${WEB_SERVER_COMMUNICATION_EMAIL} WEB_SERVER_ADMIN_PASSWORD=${WEB_SERVER_ADMIN_PASSWORD} WEB_SERVER_ADMIN_USERNAME=${WEB_SERVER_ADMIN_USERNAME} WEB_SERVER_ADMIN_EMAIL=${WEB_SERVER_ADMIN_EMAIL} && mongosh < /docker-entrypoint-initdb.d/mongo-init.js \""

    eval "$command"
}


create_mongo_database_helper(){

    printf "\nCreating database....\n"

    instance_type="6-2"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nMongo server instance....\n"

    install_folder_destination="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)"
    instance_file_name=$(ask_read_question_or_try_again "What db should be name this db env file  " true)
    db_mongo_instance=$(ask_read_question_or_try_again "What db instance should we create this in?  " true)
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    root_dest="$install_root/new-env-setups"

    # Create env files for install
    run_fillout_program "$env_to_create"

    filename=$(basename "$env_to_create")
    olddestdir="$root_dest/$install_folder_destination/$environment_type_defintion/$filename"
    destdir="$root_dest/$db_mongo_instance/dbs/"

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$db_mongo_instance/dbs"
    if  ! $(test -d "$destdir") ;
    then
        mkdir -p "$destdir"
    fi

    # # move files to $newdestdir 
    newdestdir="$root_dest/$db_mongo_instance/dbs/$instance_file_name"

    $(mv "$olddestdir" "$newdestdir")
    mongo_id=$(get_services_ids_by_service_name "$db_mongo_instance")
    env_vars=$(cat "$newdestdir" | tr '\n' " ")

    command="docker exec -it ${mongo_id} sh -c \"export ${env_vars} && mongosh < /docker-entrypoint-initdb.d/mongo-init.js\""
    eval "$command"
    rm -r "$root_dest/$install_folder_destination/"

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

    # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Webserver-Mongo-dev.docker.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Webserver-Mongo-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

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

#todo - test that this works all the way from the beginning 
initiate_mongo_process_to_replica_set(){

    primary_mongo_service_name="${1}"
    replica_set_id="${2}"
    hostname="${3}"
    port="${4}"
    priority="${5}"

    if [ $( $hostname | wc -m ) eq 0 ]; then
        hostname=$(get_current_server_ip)
    fi 

    if [ $( $priority | wc -m ) eq 0 ]; then
        priority=1
    fi 

    config="rs.initate(); config= { '_id' : '${replica_set_id}', 'members':[ { '_id' : 0, 'host' : '${IP}:${port}', priority: ${priority} } ] }; rs.reconfig(config);"

    command="docker exec -it ${primary_mongo_service_name} mongosh --eval \"${config}\""
    eval "$command"

}

#todo
add_mongo_process_to_replica_set(){

    primary_mongo_service_name="${1}"
    new_mongo_service_name="${2}"
    command="docker exec -it ${primary_mongo_service_name} mongosh --eval \"rs.add({host: '${new_mongo_service_name}' })\" "
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


copy_file_into_container(){
    container_id="${1}"
    file="${2}"
    location="${3}"
    command="docker cp ${file} ${container_id}:${location}"
    eval "$command"
}