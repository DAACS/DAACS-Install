#!/bin/bash
source "$current_dir/instance_helpers/basic.sh"

: '
Instructions:
    Pick install destination
    Pick web server destination relative from install destination
    Pick frontend folder relative from install destination 
    # Pick install env path if differs from base env
'


create_qserver_instance_helper(){


    instance_type=$1
    install_env_path=$2 #/root/DAACS-Install/DAACS-Install_Defaults
    environment_type=$3
    install_root=$4 #/root/DAACS-Install

    printf "\nCREATING Q server instance....\n"

    read -p "Enter absolute path destination for install of DAACS: " base_path_folder_destination
    read -p "Enter folder destination for install of DAACS: " install_folder_destination
    read -p "Enter name for mongo service (todo check for clashes before moving on): " mongo_service_name
    read -p "Enter name for q server service (todo check for clashes before moving on): " qserver_service_name
    
    if [ "$base_path_folder_destination" = "" ]; 
    then
        echo "Please choose an base install destination."
        exit 1
    fi

    if [ "$install_folder_destination" = "" ]; 
    then
        echo "Please choose an install destination."
        exit 1
    fi

    if [ "$mongo_service_name" = "" ]; then
        echo "Cannot leave docker mongo service name empty."
        exit -1
    fi

    if [ "$qserver_service_name" = "" ]; then
        echo "Cannot leave docker Q service name empty."
        exit -1
    fi
    

    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$1")

    # # Create env files for install
    run_fillout_program "$env_to_create"

    # # get code from repo
    clone_repo "$base_path_folder_destination" "$install_folder_destination" "git@github.com:moomoo-dev/DAACS-Qserver.git"
        
    # # # # install node modules for q server
    get_node_modules "$base_path_folder_destination/$install_folder_destination" 

    root_dest="$install_root/new-env-setups"

    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$foldername"
    if  ! $(test -d "$root_dest/$install_folder_destination/docker/") ;
    then
        mkdir -p "$root_dest/$install_folder_destination/docker/"
    fi

    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"

    # # filename - enviroment variables for webserver
    env_queueserver_file="${absolute_dir}queueserver"
    # # filename - enviroment variables for webserver mongo
    env_queue_mongo_file="${absolute_dir}queuemongo"

    mongo_container_name=$(get_environment_value_from_file_by_env_name "${env_queue_mongo_file}" "MONGODB_CONTAINER_NAME")
    mongo_port=$(get_environment_value_from_file_by_env_name "${env_queue_mongo_file}" "MONGODB_MAPPED_PORT")
    qserver_container_name=$(get_environment_value_from_file_by_env_name "${env_queueserver_file}" "WEBSERVER_CONTAINER_NAME")

    docker_file=""

        case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Queueserver.dev.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Queueserver.prod.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    webserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#mongo_service_name/$mongo_service_name/g ; s/#qserver_service_name/$qserver_service_name/g" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    env_dir="ENV_DIR=$absolute_dir"

    env_string="${local_path_to_mongo_dir} ${folder_start_env} ${env_dir} ${mongo_container_name} ${mongo_port} ${qserver_container_name}"
    
    run_docker_with_envs "$webserver_docker_file_to" "$env_string"

}