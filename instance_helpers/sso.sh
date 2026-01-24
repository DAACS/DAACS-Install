#!/bin/bash

source "$current_dir/instance_helpers/basic.sh"

sso_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nShibboleth IDP instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    new_or_update=$(ask_read_question_or_try_again "(NIDP)New IDP or (UIDP) Update IDP: " true)

    case "$new_or_update" in
    "NIDP") 
        create_web_idp_helper 
    ;;

    "UIDP") 
        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_exist == true && $does_dir_env == true ]]; then
            update_web_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi
    ;;

    *)
        echo "Invalid option"
    ;;
    esac
}


create_web_idp_helper(){


    # printf "\nCREATING Web instance....\n"
 
    # env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    # environment_type_defintion=$(get_env_type_definition "$environment_type")
    # instance_type_defintion=$(get_instance_type_definition "$instance_type")
    # root_dest="$install_root/new-env-setups"
    # absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    # mongo_service_name=$(ask_for_docker_service_and_check "Enter name for mongo service : " )
    # webserver_service_name=$(ask_for_docker_service_and_check "Enter name for web service : " )

    # # Create env files for install
    # instance_home_folder="$root_dest/$install_folder_destination"
    # run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type"

    # run_clone_repo_for_web "$environment_type" "$base_path_folder_destination" "$install_folder_destination"

    # # # # # # install node modules for web server
    # get_node_modules "$base_path_folder_destination/$install_folder_destination/$web_server_path/" 

    # # # # # # install node modules for frontend
    # get_node_modules "$base_path_folder_destination/$install_folder_destination/$frontend_path/"

    # create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # # filename - enviroment variables for webserver
    # env_webserver_file="${absolute_dir}webserver"
    # env_webserver_mongo_file="${absolute_dir}webserver-mongo"
    # env_webserver_replicas_file="${absolute_dir}webserver-replicas"

    # mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_CONTAINER_NAME")
    # mongo_port=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_MAPPED_PORT")
    # webserver_port=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PORT")
    # webserver_replicas=$(get_environment_value_from_file_by_env_name "${env_webserver_replicas_file}" "REPLICAS")

    # mongo_port_value=$(get_env_value "$mongo_port" )

    # # Checks to see if port is being used by something else and ask for a different port
    # check_if_port_is_being_used "$mongo_port" "$env_webserver_mongo_file" "mongo"

    # if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
    #     create_docker_network "$MY_DOCKER_NETWORK_NAME"
    # fi

    # # # # Create directories needed for DAACS-Server-Folders/ 
    # daacs_server_folder_dir="$base_path_folder_destination/$install_folder_destination/DAACS-Server-Folders"
    # mkdir -p "${daacs_server_folder_dir}"

    # uploads_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "SERVER_UPLOADS_DIR")
    # mkdir -p "${daacs_server_folder_dir}/${uploads_dir##*=}"

    # pdf_uploads_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "PDF_UPLOADS_DIR")
    # mkdir -p "${daacs_server_folder_dir}/${pdf_uploads_dir##*=}"

    # saml_keys_dir=$(get_environment_value_from_file_by_env_name "${env_webserver_file}" "SAML_KEYS_DIR")
    # mkdir -p "${daacs_server_folder_dir}/${saml_keys_dir##*=}"

    # # Build frontend
    # env_oauth_file="${absolute_dir}oauth"
    # api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")

    # run_build_frontend "$environment_type" "$api_client_id" "$base_path_folder_destination/$install_folder_destination/$frontend_path/"

    # docker_file=$(get_webserver_docker_filename "$environment_type_defintion")

    # webserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#mongo_service_name/$mongo_service_name/g ; s/#webserver_service_name/$webserver_service_name/g" $docker_file)

    # absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    # full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    # full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    # local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    # folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    # env_dir="ENV_DIR=$absolute_dir"

    # env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${webserver_port} ${webserver_replicas} ${mongo_container_name} ${mongo_port}"

    # run_docker_with_envs "$webserver_docker_file_to" "$env_string"

    # services_file_dir="$root_dest/$install_folder_destination/services"
    # mkdir -p "$services_file_dir"
    # add_services_service_file "$webserver_service_name" "$services_file_dir/$webserver_service_name"
    # add_services_service_file "$mongo_service_name" "$services_file_dir/$mongo_service_name"

}




update_web_instance_helper(){


}