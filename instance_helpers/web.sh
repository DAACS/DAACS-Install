#!/bin/bash
source "$current_dir/instance_helpers/basic.sh"

: '
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
    new_or_update=$(ask_read_question_or_try_again "(n)ew or (u)pdate or (r)efresh: " true)
  
  
    if [ "$web_server_path" = "" ]; 
    then
        web_server_path="DAACS-Webserver"
    fi

    if [ "$frontend_path" = "" ]; then
        frontend_path="DAACS-Frontend"
    fi

    case "$new_or_update" in
    "n") 
        
        create_web_instance_helper 
    ;;

    "u") 
        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_exist == true && $does_dir_env == true ]]; then
            update_web_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi
    ;;
    
    "r") 
        refresh_service_name=$(ask_read_question_or_try_again "service name: " false)
        stagger_count=$(ask_read_question_or_try_again "stagger count: " false)
        quiet_mode=$(ask_read_question_or_try_again "Output? : " false)

            refresh_web_instance_helper "$install_root" "$install_folder_destination" "$refresh_service_name" "$stagger_count" "$quiet_mode"
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

    mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " )
    webserver_service_name=$(ask_for_docker_service_and_check "Enter name for web service : " )

    # Create env files for install
    run_fillout_program "$env_to_create"

    # # # get code from repo
    if [ "$environment_type" = "prod" ]; then
        clone_repo "$base_path_folder_destination" "$install_folder_destination" "https://github.com/DAACS/DAACS-Website.git"
    fi

    if [ "$environment_type" = "dev" ]; then
        clone_repo "$base_path_folder_destination" "$install_folder_destination" "git@github.com:DAACS/DAACS-Website.git"
    fi

    # # # # # install node modules for web server
    get_node_modules "$base_path_folder_destination/$install_folder_destination/$web_server_path/" 

    # # # # # install node modules for frontend
    get_node_modules "$base_path_folder_destination/$install_folder_destination/$frontend_path/"


    # # build frontend
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$foldername"
    if  ! $(test -d "$root_dest/$install_folder_destination/docker/") ;
    then
        mkdir -p "$root_dest/$install_folder_destination/docker/"
    fi

    # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    webserver_replicas=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "REPLICAS")
    webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")

    todo check to see if port is being used for mongo only - if being used need to get a new port $mongo_port

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

    if [ "$environment_type" = "prod" ]; then
        catted="export ${api_client_id} && npx ember build --prod"

    fi

    if [ "$environment_type" = "dev" ]; then
        catted="export ${api_client_id} && npx ember build" 
    fi

    cd "$base_path_folder_destination/$install_folder_destination/$frontend_path/"
    eval "$catted"  

    docker_file=""

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

    should_rebuild_frontend=$(ask_read_question_or_try_again "Should I rebuild frontend? (y)es or (n)o : " true)
    should_get_latest=$(ask_read_question_or_try_again "Should I get latest code? (y)es or (n)o : " true)
    should_update_envs=$(ask_read_question_or_try_again "Should I update envs? (y)es or (n)o : " true)
  
    # # # # get code from repo
    if [ "$should_get_latest" = "y" ]; then
        get_repo_latest "$base_path_folder_destination" "$install_folder_destination" 
    fi

    # #Check to see if package.json or package.json.lock file has changed to redownload node_modules -todo
    root_dest="$install_root/new-env-setups"
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")

    # # build frontend
    env_to_create=$(get_env_files_for_updating "$root_dest/$install_folder_destination" $environment_type)
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    if [ "$should_update_envs" = "y" ]; then
        # Update env files for updating service
        run_fillout_program_for_update "$env_to_create"
    fi

    # # filename - enviroment variables for webserver
    env_webserver_file="${absolute_dir}webserver"
    # # filename - enviroment variables for webserver mongo
    env_webserver_mongo_file="${absolute_dir}webserver-mongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    webserver_replicas=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "REPLICAS")
    webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")
    
    # # Build frontend
    env_oauth_file="${absolute_dir}oauth"
    api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
    
    if [ "$should_rebuild_frontend" = "y" ]; then

        if [ "$environment_type" = "prod" ]; then
            catted="export ${api_client_id} && npx ember build --prod"

        fi

        if [ "$environment_type" = "dev" ]; then
            catted="export ${api_client_id} && npx ember build" 
        fi

        cd "$base_path_folder_destination/$install_folder_destination/$frontend_path/"
        eval "$catted"  
    fi


    docker_file=""

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

refresh_web_instance_helper(){

    root_dest="$1/new-env-setups"
    services_file_dir="$root_dest/$2/services"
    service_name="$3"
    count="$4"
    q_mode="$5"

    refresh_instance_helper "$root_dest" "$services_file_dir" "$service_name" "$count" "$q_mode"

}
