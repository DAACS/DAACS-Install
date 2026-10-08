


run_clone_repo_for_web(){

    # ${1}=environment_type
    # ${2}=base_path_folder_destination
    # ${3}=install_folder_destination
    # ${4}=branch

        # # # # get code from repo
    if [ "${1}" = "prod" ]; then
        clone_repo "${2}" "${3}" "git@github.com:DAACS/DAACS-Website.git" "${4}"
    fi

    if [ "${1}" = "dev" ]; then
        clone_repo "${2}" "${3}" "git@github.com:DAACS/DAACS-Website.git" "${4}"
    fi
}


run_build_frontend(){
    #${1}=environment_type
    #${2}=api_client_id
    #${3}=$base_path_folder_destination/$install_folder_destination/$frontend_path/

    catted=""

    if [ "${1}" = "prod" ]; then
        catted="export ${2} && npx ember build --prod"
    fi

    if [ "${1}" = "dev" ]; then
        catted="export ${2} && npx ember build" 
    fi

    cd "${3}"

    eval "$catted"  
}


get_webserver_docker_filename(){
    #${1}=environment_type_defintion

    return_file=""

    case "${1}" in
        "env-dev") 
            return_file="Docker-Webserver-dev.docker.yml"
        ;;
        "env-prod") 
            return_file="Docker-Webserver-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    echo "$return_file"

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


get_mongo_values_for_web_instance() {
    environment_type_defintion="${1}"
    root_dest="${2}"
    service_name="${3}"
    
    # mongo_database_directory=
    # database_instance_type_defintion=
    

    database_config_path=$root_dest/$service_name/$environment_type_defintion/$environment_type_defintion-/database-config/$service_name

    database_instance_type_defintion=$(get_environment_value_from_file_by_env_name "$database_config_path" "DB_TYPE") 
    mongo_folder=$(get_environment_value_from_file_by_env_name "$database_config_path" "DATABASE_FOLDER") 
    mongo_database_directory=$(get_environment_value_from_file_by_env_name "$database_config_path" "DATABASE_NAME") 

    database_instance_type_defintion=$(get_env_value "$database_instance_type_defintion" )
    mongo_folder=$(get_env_value "$mongo_folder" )
    mongo_database_directory=$(get_env_value "$mongo_database_directory" )


    absolute_database_dir="$root_dest/$mongo_folder/databases/$mongo_database_directory/"
    absolute_env_dir="$root_dest/$mongo_folder/$environment_type_defintion/$environment_type_defintion-"
    env_oauth_file="${absolute_database_dir}oauth"
    env_webserver_mongo_file="${absolute_database_dir}webserver-mongo"
    mongo_manual_set_mongo=""
    mongo_username=""
    mongo_password=""
    mongo_database_name=""
    api_client_id=""
    mongo_replica_host_list=""
    mongodb_replica_set_id=""
    mongo_manual_set_mongo=""


    case "$database_instance_type_defintion" in
        "S" | "M" ) 

            env_mongo_file_db="${absolute_env_dir}webserver-mongo"

            if [ "$should_update_envs" = "y" ]; then
                # Update env files for updating service
                run_fillout_program_for_update "$env_webserver_mongo_file"
                run_fillout_program_for_update "$env_oauth_file"
                run_fillout_program_for_update "$env_mongo_file_db"
            fi

            if [ "$database_instance_type_defintion" = "M" ]; then

                mongo_manual_set_mongo="MONGO_MANUAL_MODE=true"

            fi

            mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_mongo_file_db}" "MONGODB_CONTAINER_NAME")
            mongo_port=$(get_environment_value_from_file_by_env_name "${env_mongo_file_db}" "MONGODB_MAPPED_PORT")

            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")

        ;;
        
        "R")  


            if [ "$should_update_envs" = "y" ]; then
                # Update env files for updating service
                run_fillout_program_for_update "$env_webserver_mongo_file"
                run_fillout_program_for_update "$env_oauth_file"

                # for mongo replica updates
                replicas_env_directory="$install_root/new-env-setups/$mongo_folder/docker"
                for entry in "$replicas_env_directory"/*
                    do
                    if [ $(does_file_exsist "$entry/env-$environment_type/env-$environment_type-webserver-mongo") = true ]; then
                        run_fillout_program_for_update "$entry/env-$environment_type/env-$environment_type-webserver-mongo"

                    fi
                done
            fi

            
            mongo_username=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_USERNAME")
            mongo_password=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_PASSWORD")
            mongo_database_name=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGODB_DATABASE_NAME")
            mongo_replica_set_mongo=$(get_environment_value_from_file_by_env_name "${env_webserver_mongo_file}" "MONGO_REPLICA_SET_MODE")
            api_client_id=$(get_environment_value_from_file_by_env_name "${env_oauth_file}" "API_CLIENT_ID")
            
            replicas_env_directory="$install_root/new-env-setups/$mongo_folder/docker"
            mongo_replica_data=$(generate_webserver_replica_mongo_connection_string  "$environment_type" "" "$replicas_env_directory")
            IFS=' ' read -ra locarr <<< "$mongo_replica_data"
            mongo_replica_host_list="MONGO_REPLICA_HOST_LIST=\"${locarr[0]}\""
            mongodb_replica_set_id="MONGODB_REPLICA_SET_ID=\"${locarr[1]}\""


        ;;




    esac

        echo " ${mongo_port} ${mongo_username} ${api_client_id} ${mongo_password} ${mongo_database_name} ${mongo_replica_set_mongo} ${mongodb_replica_set_id} ${mongo_replica_host_list} ${mongo_container_name} ${mongo_manual_set_mongo} "
    
}
