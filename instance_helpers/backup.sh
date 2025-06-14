#!/bin/bash 

: '

Instance types

    Backup job
    
Actions
    Create Backup job instance
    Update Backup job instance

Instructions:
    Pick install destination
    Pick Nginx server destination relative from install destination
    # Pick install env path if differs from base env
'

backup_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nBackup instance....\n"
    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    folder_name=$(ask_read_question_or_try_again "Enter name of folder of service to backup: " true)
    instance_name=$(ask_read_question_or_try_again "Enter name of instance to backup: " true)

    if [ $(does_service_exsist $instance_name) = false ]; then
        pretty_print "${Color_Off}${Red}Missing service, or invalid service name...\n"
        return 
    fi

    new_or_update=$(ask_read_question_or_try_again "(n)ew or (u)pdate: " true)
    
    case "$new_or_update" in
    "n") 
        
        create_backup_instance_helper
    ;;

    "u") 

        

        does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_exist == true && $does_dir_env == true ]]; then
            update_backup_instance_helper
        else
            echo "Is dir missing: $does_dir_exist or Is env missing: $does_dir_env"
        fi


    ;;
    
    *)
        echo "Invalid option"
    ;;
    esac
}

create_backup_instance_helper(){

    printf "\nCREATING backup instance....\n"

    backup_service_name=$(ask_for_docker_service_and_check "Enter name for backup service: " )

    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    root_dest="$install_root/new-env-setups"
    
    # # # Create env files for install
    run_fillout_program "$env_to_create"

    backup_env_file_path="$install_root/new-env-setups/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    mongo_env_file_path="$install_root/new-env-setups/$folder_name/$environment_type_defintion/$environment_type_defintion-"

    # get code from repo
    if [ "$environment_type" = "prod" ]; then
        clone_repo "$base_path_folder_destination" "$install_folder_destination" "https://github.com/DAACS/DAACS-Backup.git"
    fi

    if [ "$environment_type" = "dev" ]; then
        clone_repo "$base_path_folder_destination" "$install_folder_destination" "git@github.com:DAACS/DAACS-Backup.git"
    fi


    # # # # # # # # install node modules for web server
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

    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    webserver_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#backup_service_name/$backup_service_name/g " $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    backup_env_dir="BACKUP_ENV_DIR=$backup_env_file_path"
    mongo_env_dir="MONGO_ENV_DIR=$mongo_env_file_path"
    pwd="DIR=$install_env_path/$instance_type_defintion/docker/"

    env_string="${folder_start_env} ${backup_env_dir} ${mongo_env_dir} ${pwd} "
    run_docker_with_envs "$webserver_docker_file_to" "$env_string"
    
    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$backup_service_name" "$services_file_dir/$backup_service_name"

}   




update_backup_instance_helper(){

    printf "\nUPDATING backup instance....\n"

    read -p "Should I get latest code? (y)es or (n)o: " should_get_latest
    read -p "Should I update envs? (y)es or (n)o: " should_update_envs
  
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

    if [ "$should_update_envs" = "y" ]; then
        # Update env files for updating service
        run_fillout_program_for_update "$env_to_create"
    fi

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

    backup_env_file_path="$install_root/new-env-setups/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    mongo_env_file_path="$install_root/new-env-setups/$folder_name/$environment_type_defintion/$environment_type_defintion-"

    backup_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"
    folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    backup_env_dir="BACKUP_ENV_DIR=$backup_env_file_path"
    mongo_env_dir="MONGO_ENV_DIR=$mongo_env_file_path"
    pwd="DIR=$install_env_path/$instance_type_defintion/docker/"

    env_string="${folder_start_env} ${backup_env_dir} ${mongo_env_dir} ${pwd} "
    run_docker_with_envs "$backup_docker_file_to" "$env_string"

   services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done

}