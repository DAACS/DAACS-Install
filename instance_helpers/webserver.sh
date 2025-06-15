source "$current_dir/instance_helpers/webserver-helpers.sh"

: '
Comments
    Move this file to web.sh and then rename it to webserver.sh


Instance types

    Webserver
    

Actions
    Create Webserver instance
    Update Webserver instance

'

webserver_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nWeb instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    web_server_path=$(ask_read_questgion_or_try_again "Enter folder name for install of DAACS web server (Relative to install path): " false)
    frontend_path=$(ask_read_question_or_try_again "Enter folder name for install of DAACS frontend (Relative to install path): " false)
    new_or_update=$(ask_read_question_or_try_again "(n)ew or (u)pdate: " true)
  
  
    if [ "$web_server_path" = "" ]; 
    then
        web_server_path="DAACS-Webserver"
    fi

    if [ "$frontend_path" = "" ]; then
        frontend_path="DAACS-Frontend"
    fi

    case "$new_or_update" in
    "n") 
        
        create_webserver_instance_helper 
    ;;

    "u") 
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

update_webserver_instance_helper(){
    
    env_webserver_file=""
    env_webserver_mongo_file=""
    mongo_container_name=""
    mongo_port=""
    mongo_username=""
    mongo_password=""
    mongo_database_name=""
    webserver_replicas=""
    webserver_port=""
    mongo_replica_set_mongo=""
    mongo_replica_id=""
    mongo_replica_host_list=""
    mongo_envs="" 

    printf "\nUpdating Webserver instance....\n"

    # #Check to see if package.json or package.json.lock file has changed to redownload node_modules -todo
    root_dest="$install_root/new-env-setups"
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    absolute_dir="$root_dest/$install_folder_destination"
    env_absolute_dir="$absolute_dir/$environment_type_defintion/"

    should_rebuild_frontend=$(ask_read_question_or_try_again "Should I rebuild frontend? (y)es or (n)o: " true)
    should_get_latest=$(ask_read_question_or_try_again "Should I get latest code? (y)es or (n)o: " true)
    should_update_envs=$(ask_read_question_or_try_again "Should I update envs? (y)es or (n)o: " true)
 
    database_instance_type_defintion=$(ask_for_docker_service_and_check "(S)ingle, (R)eplica  : " true)

    # # # # get code from repo
    if [ "$should_get_latest" = "y" ]; then
        get_repo_latest "$base_path_folder_destination" "$install_folder_destination" 
    fi

    # # build frontend
    env_to_create=$(get_env_files_for_updating "$root_dest/$install_folder_destination" $environment_type)

    if [ "$should_update_envs" = "y" ]; then
        # Update env files for updating service
        run_fillout_program_for_update "$env_to_create"
    fi

    case "$database_instance_type_defintion" in
        #todo -test
        "S") 
            mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            mongo_folder_filename=$(ask_read_question_or_try_again "Enter mongo login file (in dbs): " true)

            destdir="$root_dest/$mongo_folder"
            destdirdbs="$destdir/dbs/$mongo_folder_filename"

            files=($destdir/$environment_type_defintion/*)
            destdirenvlogin="${files[0]}"


             #todo  - test this to make sure oauth actually reads

            env_oauth_file="${env_absolute_dir}$environment_type_defintion-oauth"

            
            mongo_username=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "MONGODB_DATABASE_NAME")
            api_client_id=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "API_CLIENT_ID")
            mongo_container_name=$(get_environment_value_from_file_by_env_name "${destdirenvlogin}" "MONGODB_CONTAINER_NAME")
            mongo_port=$(get_environment_value_from_file_by_env_name "${destdirenvlogin}" "MONGODB_MAPPED_PORT")

        ;;
        
        "R")  
           
            env_webserver_mongo_file="${env_absolute_dir}$environment_type_defintion-webserver-mongo"
            #todo  - test this to make sure oauth actually reads

            env_oauth_file="${env_absolute_dir}$environment_type_defintion-oauth"

            #create env file
            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            mongo_replica_set_mongo=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_REPLICA_SET_MODE")
            mongo_replica_id=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_REPLICA_ID")
            mongo_replica_host_list=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_REPLICA_HOST_LIST")
            mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
            

            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")

        ;;
    esac

    mongo_envs=" ${mongo_port} ${mongo_username} ${api_client_id} ${mongo_password} ${mongo_database_name} ${mongo_replica_set_mongo} ${mongo_replica_id} ${mongo_replica_host_list} ${mongo_container_name} "


    # filename - enviroment variables for webserver
    env_webserver_file="${env_absolute_dir}$environment_type_defintion-webserver"
    webserver_replicas_file="${env_absolute_dir}$environment_type_defintion-webserver-replicas"

    webserver_replicas=$(get_environment_value_from_file_by_env_name "${webserver_replicas_file}" "REPLICAS")

    webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")
    
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
    env_dir="ENV_DIR=$env_absolute_dir$environment_type_defintion-"

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_envs} "

    run_docker_with_envs "$webserver_docker_file_to" "$env_string"
    
    services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done
    
}