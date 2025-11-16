#!/bin/bash
source "$current_dir/instance_helpers/basic.sh"

: '
Instance types

    Memcached D

Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'


# MONGO_REPLICA_IMAGE_NAME="mongo-replica"
# MONGO_IMAGE_NAME="daacs-mongo"
MY_DOCKER_NETWORK_NAME="myNetwork"

memcached_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nMemcached server instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    new_or_update=$(ask_read_question_or_try_again "(n)ew or (u)pdate  : " true)
    
    case "$new_or_update" in

    "n") 
        
        create_memcached_instance_helper
    ;;


    "u") 

        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_env == true ]]; then
            update_memcached_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi

    ;;
    
    
    *)
        echo "Invalid option"
    ;;
    esac
}


create_memcached_instance_helper(){

    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    # qserver_files_to="$install_env_path/$instance_type_defintion/docker/Dockerfile-webserver-mongo-dev"
    # create_image "$qserver_files_to" "${MONGO_IMAGE_NAME}" "$install_env_path/$instance_type_defintion/docker/" 
 
    printf "\nCREATING Memcached server instance....\n"

    memcached_service_name=$(ask_for_docker_service_and_check "Enter name for memcached service : " true)
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    memcached_docker_directory="$root_dest/$install_folder_destination"

    # Create env files for install
    create_directory_if_it_does_exsist "$memcached_docker_directory/docker/"

    instance_home_folder="$root_dest/$install_folder_destination"
    run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type_defintion"

    env_memcached_file="${absolute_dir}memcached"
    docker_file=$(get_memcached_docker_filename "$environment_type_defintion")

    memcached_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#memcached_service_name/$memcached_service_name/g ;" $docker_file)
    echo "$memcached_docker_file_to"

    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi


    # # Checks to see if port is being used by something else and ask for a different port
    # check_if_port_is_being_used $(get_environment_value_from_file_by_env_name "${env_memcached_file}" "MEMCACHED_MAPPED_PORT") "$env_memcached_file" "memcached"

    memcached_mapped_port=$(get_environment_value_from_file_by_env_name "${env_memcached_file}" "MEMCACHED_MAPPED_PORT")
    memcached_container_name=$(get_environment_value_from_file_by_env_name "${env_memcached_file}" "MEMCACHED_CONTAINER_NAME")
    env_string="${memcached_mapped_port} ${env_dir} ${memcached_container_name} "

    run_docker_with_envs "$memcached_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    create_directory_if_it_does_exsist "$services_file_dir"

    add_services_service_file "$memcached_service_name" "$services_file_dir/$memcached_service_name"

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
    docker_file=$(get_memcached_docker_filename "$environment_type_defintion")
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


get_memcached_docker_filename(){
    return_file=""
    case "$environment_type_defintion" in
    "env-dev") 
        return_file="Docker-Memcached.dev.yml"
    ;;
    "env-prod") 
        return_file="Docker-Memcached.prod.yml"
    ;;
    *)
        echo "Invalid instance option"
        exit -1
    ;;
    esac
    echo "$return_file"
}


