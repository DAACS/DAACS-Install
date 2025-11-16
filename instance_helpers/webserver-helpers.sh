


run_clone_repo_for_web(){

    # ${1}=environment_type
    # ${2}=base_path_folder_destination
    # ${3}=install_folder_destination

        # # # # get code from repo
    if [ "${1}" = "prod" ]; then
        clone_repo "${2}" "${3}" "https://github.com/DAACS/DAACS-Website.git"
    fi

    if [ "${1}" = "dev" ]; then
        clone_repo "${2}" "${3}" "git@github.com:DAACS/DAACS-Website.git"
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