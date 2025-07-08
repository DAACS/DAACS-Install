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
    instance_home_folder="$root_dest/$install_folder_destination"
    run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type"

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
    mongo_manual_set_mongo=""

    manual_or_on_site_env=$(ask_read_question_or_try_again "(m)anual or  (a)utomatic?: " false)
    root_dest="$install_root/new-env-setups"

    case "$database_instance_type_defintion" in
        "S") 
        
            if [ "$manual_or_on_site_env" = "m" ]; then


                mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
                mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)
                mongo_container_name=$(ask_read_question_or_try_again "Enter mongo container/host/IP: " false)
                mongo_port=$(ask_read_question_or_try_again "Enter mongo port: " false)
                mongo_username=$(ask_read_question_or_try_again "Enter mongo username: " false)
                mongo_password=$(ask_read_question_or_try_again "Enter mongo mongo_password: " false)
                mongo_database_name=$mongo_database_directory
                api_client_id=$(ask_read_question_or_try_again "Enter mongo api client id: " false)

                mong_env_file_dir1="$root_dest/$mongo_folder/databases/$mongo_database_directory"
                create_directory_if_it_does_exsist "$mong_env_file_dir1"

                mongo_manual_set_mongo="MONGO_MANUAL_MODE=true"

                write_file2="MONGO_USERNAME=${mongo_username}\nMONGO_PASSWORD=${mongo_password}\nMONGODB_DATABASE_NAME=${mongo_database_name}\n${mongo_replica_set_mongo}\n${mongo_manual_set_mongo}\n"

                webserver_mongo1="$mong_env_file_dir1/webserver-mongo"
                create_directory_if_it_does_exsist "${mong_env_file_dir1}"
                touch "$webserver_mongo1"
                printf "$write_file2" > "$webserver_mongo1"

                write_file3="API_CLIENT_ID=${api_client_id}\n"
                webserver_mongo2="$mong_env_file_dir1/oauth"
                touch "$webserver_mongo2"
                printf "$write_file3" > "$webserver_mongo2"


                mong_env_file_dir2="$root_dest/$mongo_folder"
                create_directory_if_it_does_exsist "$mong_env_file_dir2"
                write_file1="MONGODB_CONTAINER_NAME=${mongo_container_name}\nMONGODB_MAPPED_PORT=${mongo_port}\n"
                write_env_to_file_new "$write_file1" "$environment_type_defintion" "$mong_env_file_dir2" "$environment_type_defintion-webserver-mongo"
  

                env_oauth_file="${mong_env_file_dir1}/oauth"
                env_webserver_mongo_file="${mong_env_file_dir1}/webserver-mongo"
                env_mongo_file_db="${mong_env_file_dir2}/${environment_type_defintion}/${environment_type_defintion}-webserver-mongo"

                mongo_port=$(get_environment_value_from_file_by_env_name "${env_mongo_file_db}" "MONGODB_MAPPED_PORT")

                mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
                mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
                mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
                mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")

                api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")

            else


                mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
                mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)
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

            fi

           
        ;;
        
        "R") 
            
            mongo_replica_set_mongo="MONGO_REPLICA_SET_MODE=true"
           
            mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)

            absolute_database_dir="$root_dest/$mongo_folder/databases/$mongo_database_directory/"
            env_oauth_file="${absolute_database_dir}oauth"
            env_webserver_mongo_file="${absolute_database_dir}webserver-mongo"

            if [ "$manual_or_on_site_env" = "m" ]; then

                create_mongo_files=$(ask_read_question_or_try_again "Create Mongo Replica files? : " true)
                create_mongo_database_files=$(ask_read_question_or_try_again "Create Mongo Replica database files? : " true)

                if [ "$create_mongo_files" = "true" ]; then
                    create_mongo_replica_connection_files "$environment_type" "$mongo_folder"
                fi

                if [ "$create_mongo_database_files" = "true" ]; then
                    create_database_files "$mongo_database_directory" "$mongo_folder"
                fi

            fi

            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
            
            replicas_env_directory="$install_root/new-env-setups/$mongo_folder/docker"
            mongo_replica_data=$(generate_webserver_replica_mongo_connection_string  "$environment_type" "" "$replicas_env_directory")
            IFS=' ' read -ra locarr <<< "$mongo_replica_data"
            mongo_replica_host_list="MONGO_REPLICA_HOST_LIST=\"${locarr[0]}\""
            mongodb_replica_set_id="MONGODB_REPLICA_SET_ID=\"${locarr[1]}\""
       
        ;;
    esac

    # Create env files for install
    run_fillout_program "$env_to_create"

    # instance_home_folder="$root_dest/$install_folder_destination"
    # run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type"

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
    
    env_string="${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_container_name} ${mongo_port} ${mongo_username} ${mongo_password} ${mongo_database_name} ${mongo_replica_host_list} ${mongodb_replica_set_id} ${mongo_replica_set_mongo} ${mongo_manual_set_mongo}"

    run_docker_with_envs "$webserver_docker_file_to" "$env_string" true
    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$webserver_service_name" "$services_file_dir/$webserver_service_name"

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
    mongodb_replica_set_id=""
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
    
    
            # mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            # mongo_folder_filename=$(ask_read_question_or_try_again "Enter mongo login file (in dbs): " true)
            # destdir="$root_dest/$mongo_folder"
            # destdirdbs="$destdir/dbs/$mongo_folder_filename"
            # files=($destdir/$environment_type_defintion/*)
            # destdirenvlogin="${files[0]}"
            #  #todo  - test this to make sure oauth actually reads
            # env_oauth_file="${env_absolute_dir}$environment_type_defintion-oauth"
            # mongo_username=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "MONGO_USERNAME")
            # mongo_password=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "MONGO_PASSWORD")
            # mongo_database_name=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "MONGODB_DATABASE_NAME")
            # api_client_id=$(get_environment_value_from_file_by_env_name "${destdirdbs}" "API_CLIENT_ID")
            # mongo_container_name=$(get_environment_value_from_file_by_env_name "${destdirenvlogin}" "MONGODB_CONTAINER_NAME")
            # mongo_port=$(get_environment_value_from_file_by_env_name "${destdirenvlogin}" "MONGODB_MAPPED_PORT")

        ;;
        
        "R")  
           

            mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)
            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
            
            replicas_env_directory="$install_root/new-env-setups/$mongo_folder/docker"
            mongo_replica_data=$(generate_webserver_replica_mongo_connection_string  "$environment_type" "" "$replicas_env_directory")
            IFS=' ' read -ra locarr <<< "$mongo_replica_data"
            mongo_replica_host_list="MONGO_REPLICA_HOST_LIST=\"${locarr[0]}\""
            mongodb_replica_set_id="MONGODB_REPLICA_SET_ID=\"${locarr[1]}\""



            # mongo_folder=$(ask_read_question_or_try_again "Enter mongo folder: " false)
            # mongo_database_directory=$(ask_read_question_or_try_again "Enter database directory name: " true)
            # hostname=$(ask_read_question_or_try_again "Mongo DNS hostname? : ")
            # root_dest="$install_root/new-env-setups"
            # mongo_replica_set_mongo="MONGO_REPLICA_SET_MODE=true"
            # absolute_database_dir="$root_dest/$mongo_folder/databases/$mongo_database_directory/"
            # env_oauth_file="${absolute_database_dir}oauth"
            # env_webserver_mongo_file="${absolute_database_dir}webserver-mongo"
            # mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            # mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            # mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            # api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
            
            # if [ -z $hostname ]; then
            #     hostname=$(get_current_server_ip)
            # fi 

            # replicas_env_directory="$install_root/new-env-setups/$mongo_folder/docker"
            # mongo_replica_data=$(generate_webserver_replica_mongo_connection_string  "$environment_type" "$hostname" "$replicas_env_directory")
            # IFS=' ' read -ra locarr <<< "$mongo_replica_data"
            # mongo_replica_host_list="MONGO_REPLICA_HOST_LIST=\"${locarr[0]}\""
            # mongodb_replica_set_id="MONGODB_REPLICA_SET_ID=\"${locarr[1]}\""


        ;;
    esac

    mongo_envs=" ${mongo_port} ${mongo_username} ${api_client_id} ${mongo_password} ${mongo_database_name} ${mongo_replica_set_mongo} ${mongodb_replica_set_id} ${mongo_replica_host_list} ${mongo_container_name} "

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

generate_webserver_replica_mongo_connection_string(){

    env="${1}" #enviroment
    host_or_ip="" #enviroment
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


        host_or_ip_data=$(get_environment_value_from_file_by_env_name "${arr[$i]}" "MONGODB_HOST_OR_IP")
        host_or_ip=$(get_env_value "$host_or_ip_data" )

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
}




    create_mongo_replica_connection_files(){

        instance_type="6-3"    
        env_type=$(get_env_type_definition "${1}" )
        mongo_install_folder_destination="${2}"
        env_to_run=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
        root_dest="$install_root/new-env-setups"
    
        save_home_folder="$root_dest/$mongo_install_folder_destination/docker"
        replica_connections=$(ask_read_question_or_try_again "How many replicas are you connecting to? : " true)

        START=1
        END=$replica_connections
        for ((index = 1; index <= $replica_connections ; index++)); do
            mongo_service_name=$(ask_read_question_or_try_again "Mongo service name? : " true)
            run_fillout_program_new "$env_to_run" "$save_home_folder/${mongo_service_name}" "$env_type"
        done
        
    }


    create_database_files(){

        mongo_database_directory="${1}"
        mongo_folder="${2}"
        
        mongo_replica_set_mongo="MONGO_REPLICA_SET_MODE=true"
        
        # mongo_port=$(ask_read_question_or_try_again "Enter mongo port: " false)
        mongo_username=$(ask_read_question_or_try_again "Enter mongo username: " false)
        mongo_password=$(ask_read_question_or_try_again "Enter mongo mongo_password: " false)
        mongo_database_name=$mongo_database_directory

        api_client_id=$(ask_read_question_or_try_again "Enter mongo api client id: " false)

        mong_env_file_dir1="$root_dest/$mongo_folder/databases/$mongo_database_directory"
        create_directory_if_it_does_exsist "$mong_env_file_dir1"

        write_file2="MONGO_USERNAME=${mongo_username}\nMONGO_PASSWORD=${mongo_password}\nMONGODB_DATABASE_NAME=${mongo_database_name}\n${mongo_replica_set_mongo}\n${mongo_manual_set_mongo}\n"

        webserver_mongo1="$mong_env_file_dir1/webserver-mongo"
        touch "$webserver_mongo1"
        printf "$write_file2" > "$webserver_mongo1"


        write_file3="API_CLIENT_ID=${api_client_id}\n"
        webserver_mongo2="$mong_env_file_dir1/oauth"
        touch "$webserver_mongo2"
        printf "$write_file3" > "$webserver_mongo2"

    }