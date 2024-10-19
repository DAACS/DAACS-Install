#!/bin/bash 

create_backup_instance_helper(){

    instance_type=$1
    install_env_path=$2 #/root/DAACS-Install/DAACS-Install_Defaults
    environment_type=$3
    install_root=$4 #/root/DAACS-Install
    printf "\nCREATING backup instance....\n"

    read -p "Enter absolute path destination for install of DAACS: " base_path_folder_destination
    read -p "Enter folder destination for install of DAACS: " install_folder_destination
    read -p "Enter name for mongo service (todo check for clashes before moving on): " backup_service_name
    read -p "Enter name of instance folder to backup (todo check to see if folder exsist): " folder_instance
    
    if [ "$base_path_folder_destination" = "" ]; 
    then
        echo "Please choose an install destination path."
        exit 1
    fi    

    if [ "$install_folder_destination" = "" ]; 
    then
        echo "Please choose an folder destination name."
        exit 1
    fi

    if [ "$backup_service_name" = "" ]; then
        echo "Cannot leave docker backup service name empty."
        exit -1
    fi

    if [ "$folder_instance" = "" ]; then
        echo "Cannot folder instance dir empty."
        exit -1
    fi

    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$1")
    
    # # # Create env files for install but only if asked - todo
    run_fillout_program "$env_to_create"

    backup_env_file_path="$install_root/new-env-setups/$backup_service_name/$environment_type_defintion/$environment_type_defintion-"
    mongo_env_file_path="$install_root/new-env-setups/$folder_instance/$environment_type_defintion/$environment_type_defintion-"

    # # # # get code from repo
    clone_repo "$base_path_folder_destination" "$install_folder_destination" "git@github.com:moomoo-dev/DAACS-Backup.git"

    # # # # # # # install node modules for web server
    get_node_modules "$base_path_folder_destination/$install_folder_destination/" 

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Export.dev.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Export.prod.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    root_dest="$install_root/new-env-setups"


    # # Checks to see if directory exsist in "DAACS-Install/new-env-setups/$foldername"
    if  ! $(test -d "$root_dest/$install_folder_destination/docker/") ;
    then
        mkdir -p "$root_dest/$install_folder_destination/docker/"
    fi


    webserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#backup_service_name/$backup_service_name/g " $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    backup_env_dir="BACKUP_ENV_DIR=$backup_env_file_path"
    mongo_env_dir="MONGO_ENV_DIR=$mongo_env_file_path"
    pwd="DIR=$install_env_path/$instance_type_defintion/docker/"

    env_string="${folder_start_env} ${backup_env_dir} ${mongo_env_dir} ${pwd} "
    echo "$env_string"
    run_docker_with_envs "$webserver_docker_file_to" "$env_string"
}   