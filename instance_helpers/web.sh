#!/bin/bash
source "$current_dir/instance_helpers/basic.sh"
source "$current_dir/instance_helpers/webserver-helpers.sh"

: '
Comments
    Move "webserver.sh" to this file and make it readable


Instance types

    Webserver/Mongo
    
Actions
    Create Webserver/Mongo instance
    Update Webserver/Mongo instance

Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'

web_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nWeb instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    web_server_path=$(ask_read_question_or_try_again "Enter folder name for install of DAACS web server (Relative to install path): " false)
    frontend_path=$(ask_read_question_or_try_again "Enter folder name for install of DAACS frontend (Relative to install path): " false)
    new_or_update=$(ask_read_question_or_try_again "(NWM)New Web/Mongo or (UWM) Update Web/Mongo (NW)New Webserver or (UW) Update Webserver: " true)
  
  
    if [ "$web_server_path" = "" ]; 
    then
        web_server_path="DAACS-Webserver"
    fi

    if [ "$frontend_path" = "" ]; then
        frontend_path="DAACS-Frontend"
    fi

    case "$new_or_update" in
    "NWM") 
        create_web_instance_helper 
    ;;

    "UWM") 
        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_exist == true && $does_dir_env == true ]]; then
            update_web_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi
    ;;

    "NW") 
        create_webserver_instance_helper 
    ;;

    "UW") 
        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_exist == true && $does_dir_env == true ]]; then
            update_webserver_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi
    ;;

    *)
        echo "Invalid option"
    ;;
    esac
}



create_web_instance_helper(){

    printf "\nCREATING Web instance....\n"
 
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " )
    webserver_service_name=$(ask_for_docker_service_and_check "Enter name for web service : " )


    # Create env files for install
    run_fillout_program "$env_to_create"

    run_clone_repo_for_web "$environment_type" "$base_path_folder_destination" "$install_folder_destination"

    # # # # # install node modules for web server
    get_node_modules "$base_path_folder_destination/$install_folder_destination/$web_server_path/" 

    # # # # # install node modules for frontend
    get_node_modules "$base_path_folder_destination/$install_folder_destination/$frontend_path/"

    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"
    env_webserver_replicas_file="${absolute_dir}webserver-replicas"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")
    webserver_replicas=$(get_environment_value_from_file_by_env_name "${env_webserver_replicas_file}" "REPLICAS")

    mongo_port_value=$(get_env_value "$mongo_port" )

    # Checks to see if port is being used by something else and ask for a different port
    check_if_port_is_being_used "$mongo_port" "$env_webserver_mongo_file" "mongo"

    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    # # # Create directories needed for DAACS-Server-Folders/ 
    daacs_server_folder_dir="$base_path_folder_destination/$install_folder_destination/DAACS-Server-Folders"
    mkdir -p "${daacs_server_folder_dir}"

    uploads_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "SERVER_UPLOADS_DIR")
    mkdir -p "${daacs_server_folder_dir}/${uploads_dir##*=}"

    pdf_uploads_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PDF_UPLOADS_DIR")
    mkdir -p "${daacs_server_folder_dir}/${pdf_uploads_dir##*=}"

    saml_keys_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "SAML_KEYS_DIR")
    mkdir -p "${daacs_server_folder_dir}/${saml_keys_dir##*=}"

    # Build frontend
    env_oauth_file="${absolute_dir}oauth"
    api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")

    run_build_frontend "$environment_type" "$api_client_id" "$base_path_folder_destination/$install_folder_destination/$frontend_path/"

    docker_file=$(get_webserver_docker_filename "$environment_type_defintion")

    webserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#mongo_service_name/$mongo_service_name/g ; s/#webserver_service_name/$webserver_service_name/g" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_container_name} ${mongo_port}"

    run_docker_with_envs "$webserver_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$webserver_service_name" "$services_file_dir/$webserver_service_name"
    add_services_service_file "$mongo_service_name" "$services_file_dir/$mongo_service_name"

}

update_web_instance_helper(){
  
    printf "\nUpdating Web instance....\n"

    should_rebuild_frontend=$(ask_read_question_or_try_again "Should I rebuild frontend? (y)es or (n)o: " true)
    should_get_latest=$(ask_read_question_or_try_again "Should I get latest code? (y)es or (n)o: " true)
    should_update_envs=$(ask_read_question_or_try_again "Should I update envs? (y)es or (n)o: " true)


    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    env_to_create=$(get_env_files_for_updating "$root_dest/$install_folder_destination" $environment_type)

    if [ "$should_update_envs" = "y" ]; then
        # Update env files for updating service
        run_fillout_program_for_update "$env_to_create"

        #check to see if port update is new and if it is we need to check to see if port is being used 
    fi

    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    # # # # get code from repo
    if [ "$should_get_latest" = "y" ]; then
        get_repo_latest "$base_path_folder_destination" "$install_folder_destination" 
    fi

    # enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"
    env_webserver_replicas_file="${absolute_dir}webserver-replicas"
    env_oauth_file="${absolute_dir}oauth"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    webserver_replicas=$(get_environment_value_from_file_by_env_name "${env_webserver_replicas_file}" "REPLICAS")
    webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")
    
    # Build frontend
    api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")  
    if [ "$should_rebuild_frontend" = "y" ]; then
        run_build_frontend "$environment_type" "$api_client_id" "$base_path_folder_destination/$install_folder_destination/$frontend_path/" 
    fi

    docker_file=$(get_webserver_docker_filename "$environment_type_defintion")
    
    webserver_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )
    
    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_container_name} ${mongo_port}"

    run_docker_with_envs "$webserver_docker_file_to" "$env_string"
    
    services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done
    
}




create_webserver_instance_helper(){

    printf "\nCREATING Webserver instance....\n"

    instance_type="7"
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "7")
    database_instance_type_defintion=$(ask_for_docker_service_and_check "(S)ingle, (R)eplica  : " true)

    webserver_service_name=$(ask_for_docker_service_and_check "Enter name for web service : " )
    enter_mongo_data_manually=true

    env_webserver_file=""
    env_webserver_mongo_file=""
    mongo_container_name=""
    mongo_port=""
    mongo_username=""
    mongo_password=""
    mongo_database_name=""
    webserver_replicas=""
    webserver_port=""
    mongodb_replica_set_id=""
    mongo_replica_host_list=""
    mongo_replica_set_mongo=""
    
    case "$database_instance_type_defintion" in
        "S") 
            mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)
            root_dest="$install_root/new-env-setups"
            absolute_database_dir="$root_dest/$mongo_folder/databases/$mongo_database_directory/"
            absolute_env_dir="$root_dest/$mongo_folder/$environment_type_defintion/$environment_type_defintion-"

            env_oauth_file="${absolute_database_dir}oauth"
            env_webserver_mongo_file="${absolute_database_dir}webserver-mongo"
            env_mongo_file_db="${absolute_env_dir}webserver-mongo"

            mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_mongo_file_db}" "MONGODB_CONTAINER_NAME")
            mongo_port=$(get_environment_value_from_file_by_env_name "${env_mongo_file_db}" "MONGODB_MAPPED_PORT")

            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
        ;;
        
        "R") 
           


            mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)
            hostname=$(ask_read_question_or_try_again "Mongo DNS hostname? : ")
            root_dest="$install_root/new-env-setups"
            mongo_replica_set_mongo="MONGO_REPLICA_SET_MODE=true"
            absolute_database_dir="$root_dest/$mongo_folder/databases/$mongo_database_directory/"
            env_oauth_file="${absolute_database_dir}oauth"
            env_webserver_mongo_file="${absolute_database_dir}webserver-mongo"
            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
            
            if [ -z $hostname ]; then
                hostname=$(get_current_server_ip)
            fi 

            replicas_env_directory="$install_root/new-env-setups/$mongo_folder/docker"
            mongo_replica_data=$(generate_webserver_replica_mongo_connection_string  "$environment_type" "$hostname" "$replicas_env_directory")
            IFS=' ' read -ra locarr <<< "$mongo_replica_data"
            mongo_replica_host_list="MONGO_REPLICA_HOST_LIST=\"${locarr[0]}\""
            mongodb_replica_set_id="MONGODB_REPLICA_SET_ID=\"${locarr[1]}\""



            #TODO - add ability to write database stuff manually
            # mongo_username=$(ask_read_question_or_try_again  "MONGO_USERNAME" true)
            # mongo_password=$(ask_read_question_or_try_again  "MONGO_PASSWORD" true)
            # mongo_database_name=$(ask_read_question_or_try_again  "MONGODB_DATABASE_NAME" true)
            # api_client_id=$(ask_read_question_or_try_again "API_CLIENT_ID" true)
            # mongodb_replica_set_id=$(ask_read_question_or_try_again "MONGODB_REPLICA_SET_ID" true)
            # mongo_replica_host_list=$(ask_read_question_or_try_again "MONGO_REPLICA_HOST_LIST" true)

            # #create env file
            # write_file="${mongo_port}\n${mongo_username}\n${mongo_password}\n${mongo_database_name}\n${mongo_replica_set_mongo}\n${mongodb_replica_set_id}\n${mongo_replica_host_list}\n"
            # write_env_to_file_new "$write_file" "$environment_type_defintion" "$absolute_dir" "${environment_type_defintion}-webserver-mongo"
            # env_string="${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_container_name} ${mongo_port} ${mongo_username} ${mongo_password} ${mongo_database_name} ${mongo_replica_host_list}"

        ;;
    esac

    root_dest="$install_root/new-env-setups"

    # Create env files for install
    run_fillout_program "$env_to_create"

    run_clone_repo_for_web "$environment_type" "$base_path_folder_destination" "$install_folder_destination"

    # install node modules for web server
    get_node_modules "$base_path_folder_destination/$install_folder_destination/$web_server_path/" 

    # install node modules for frontend
    get_node_modules "$base_path_folder_destination/$install_folder_destination/$frontend_path/"

    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # build frontend
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    env_webserver_replicas_file="${absolute_dir}webserver-replicas"

    # Create directories needed for DAACS-Server-Folders/ 
    daacs_server_folder_dir="$base_path_folder_destination/$install_folder_destination/DAACS-Server-Folders"
    mkdir -p "${daacs_server_folder_dir}"

    uploads_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "SERVER_UPLOADS_DIR")
    mkdir -p "${daacs_server_folder_dir}/${uploads_dir##*=}"

    pdf_uploads_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PDF_UPLOADS_DIR")
    mkdir -p "${daacs_server_folder_dir}/${pdf_uploads_dir##*=}"

    saml_keys_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "SAML_KEYS_DIR")
    mkdir -p "${daacs_server_folder_dir}/${saml_keys_dir##*=}"

    # Build frontend
    run_build_frontend "$environment_type" "$api_client_id" "$base_path_folder_destination/$install_folder_destination/$frontend_path/"

    docker_file=$(get_webserver_docker_filename "$environment_type_defintion")

    webserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#webserver_service_name/$webserver_service_name/g" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    webserver_replicas=$(get_environment_value_from_file_by_env_name "${env_webserver_replicas_file}" "REPLICAS")
    webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")
    
    env_string="${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_container_name} ${mongo_port} ${mongo_username} ${mongo_password} ${mongo_database_name} ${mongo_replica_host_list} ${mongodb_replica_set_id} ${mongo_replica_set_mongo}"

    echo "$env_string"
    run_docker_with_envs "$webserver_docker_file_to" "$env_string" true
    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$webserver_service_name" "$services_file_dir/$webserver_service_name"

}

generate_webserver_replica_mongo_connection_string(){

    env="${1}" #enviroment
    host_or_ip="${2}" #enviroment
    env_dirr="${3}" #enviroment


    declare -a arr
    declare -a return_data
    return_string=""
    return_replica_set_id=""

    if [ $(does_directory_exsist "$env_dirr") = false ]; then
        echo "-1"
        return
    fi

    for entry in "$env_dirr"/*
    do
        if [ $(does_file_exsist "$entry/env-$environment_type/env-$environment_type-webserver-mongo") = true ]; then
            arr=("${arr[@]}" "$entry/env-$environment_type/env-$environment_type-webserver-mongo")
        fi
    done


    N="${#arr[@]}"
    if [ $N -eq 0 ];then 

        echo "-2"
        return
    fi 

    for i in "${!arr[@]}"; do 

        mongo_port=$(get_environment_value_from_file_by_env_name "${arr[$i]}" "MONGODB_MAPPED_PORT")
        mongo_port_value=$(get_env_value "$mongo_port" )

        if [ -z "$return_replica_set_id" ]; then

            replica_set_id=$(get_environment_value_from_file_by_env_name "${arr[$i]}" "MONGODB_REPLICA_SET_ID")
            replica_set_id_value=$(get_env_value "$replica_set_id" )
            return_replica_set_id=$replica_set_id_value
        fi

        if [ $i  -gt 0 ]; then
            return_string="$host_or_ip:$mongo_port_value,${return_string}"

        else
            return_string="$host_or_ip:$mongo_port_value${return_string}"
        fi

    done
    
    return_data[0]=$return_string
    return_data[1]=$return_replica_set_id
    echo "${return_data[@]}"
    # echo "$return_data"
    # echo  "$return_string"
}