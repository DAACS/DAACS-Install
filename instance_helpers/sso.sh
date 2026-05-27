#!/bin/bash

source "$current_dir/instance_helpers/basic.sh"
SHIBBOLETH_IMAGE_NAME="shibbolethreal"
MY_DOCKER_NETWORK_NAME="myNetwork"

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
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_env == true ]]; then
            update_web_idp_helper
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
    root_dest="$install_root/new-env-setups"

    instance_type_defintion=$(get_instance_type_definition "$instance_type")    
    build_file="Docker-idp-build"
    shibboleth_files_to="$install_env_path/${instance_type_defintion}/docker/${build_file}"
    create_image "$shibboleth_files_to" "${SHIBBOLETH_IMAGE_NAME}" "$install_env_path/${instance_type_defintion}/docker/" 

    printf "\nCREATING Shibboleth instance....\n"
 
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    shibboleth_service_name=$(ask_for_docker_service_and_check "Enter name for shibboleth service : " )
    ldap_service_directory=$(ask_read_question_or_try_again "Enter folder directory for LDAP envs: " true)


    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    absolute_dir_for_ldap="$root_dest/$ldap_service_directory/$environment_type_defintion/$environment_type_defintion-"
    instance_home_folder="$root_dest/$install_folder_destination"
        
    # Create env files for install
    run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type_defintion"

    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # # filename - enviroment variables for webserver
    env_shibboleth_file="${absolute_dir}shibboleth"
    env_ldap_file="${absolute_dir_for_ldap}"

    shibboleth_container_name=$(get_environment_value_from_file_by_env_name "${env_shibboleth_file}" "SHIBBOLETH_CONTAINER_NAME")
    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Shibboleth-dev.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Shibboleth-prod.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    shibboleth_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#shibboleth_service_name/$shibboleth_service_name/g ;" $docker_file)

    absolute_dir_for_ldap="$root_dest/$ldap_service_directory/$environment_type_defintion/$environment_type_defintion-"
    env_dir="ENV_DIR=$absolute_dir"
    env_ldap_file="ENV_LDAP_DIR=$absolute_dir_for_ldap"
    env_string="${env_dir} ${env_ldap_file}"

    run_docker_with_envs "$shibboleth_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$shibboleth_service_name" "$services_file_dir/$shibboleth_service_name"
    write_mongo_config_file "$absolute_dir" "$ldap_service_directory" "$shibboleth_service_name"

}

update_web_idp_helper(){

  printf "\nUPDATING Shibboleth IDP server instance....\n"

    should_update_envs=$(ask_read_question_or_try_again "Should I update envs? (y)es or (n)o: " true) 
    root_dest="$install_root/new-env-setups"
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    
    absolute_dir_for_ldap_config_file="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-/database-config/$install_folder_destination"

    ldap_folder=$(get_environment_value_from_file_by_env_name "$absolute_dir_for_ldap_config_file" "DATABASE_FOLDER") 
    mongo_database_directory=$(get_environment_value_from_file_by_env_name "$absolute_dir_for_ldap_config_file" "DATABASE_NAME") 
    absolute_dir_for_ldap_ssl="$root_dest/$(get_env_value "$ldap_folder" )/$(get_env_value "$mongo_database_directory" )"
    absolute_dir_for_ldap="$root_dest/$(get_env_value "$ldap_folder" )/$environment_type_defintion/$environment_type_defintion-"
    
    # Update env files for updating service
    env_to_create=$(get_env_files_for_updating "$root_dest/$install_folder_destination" $environment_type)
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    if [ "$should_update_envs" = "y" ]; then
        
        run_fillout_program_for_update "$env_to_create"
    fi

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-Shibboleth-dev.yml"
        ;;
        "env-prod") 
            docker_file="Docker-Shibboleth-prod.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac


    ldap_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )

    env_dir="ENV_DIR=$absolute_dir"
    env_ldap_file="ENV_LDAP_DIR=$absolute_dir_for_ldap"
    env_ldap_ssl_file="ENV_LDAP_SSL_DIR=$absolute_dir_for_ldap_ssl"
 
    env_string="${env_dir} ${env_ldap_file} ${env_ldap_ssl_file}"

    run_docker_with_envs "$ldap_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done
}

write_mongo_config_file(){

    destdir="${1}/database-config/"
    create_directory_if_it_does_exsist "$destdir"
    database_config_env="LDAP_DB_DIRECTORY=${2}"
    write_to_file "$database_config_env" "$destdir/$"
}