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

    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    # is_this_init_process=$(ask_read_question_or_try_again "Is this process the first one? (Init replica process) : " true)
    # copy_ssl_cert_from_container=$(ask_for_docker_service_and_check "Copy SSL cert from container? : " true)
    # do_create_database=$(ask_read_question_or_try_again "Do you want to create database for web server? : " true)
    
    build_file="Docker-idp-build-dev"
    shibboleth_files_to="$install_env_path/${instance_type_defintion}/docker/${build_file}"
    create_image "$shibboleth_files_to" "${SHIBBOLETH_IMAGE_NAME}" "$install_env_path/${instance_type_defintion}/docker/" 

    printf "\nCREATING Shibboleth instance....\n"
 
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    shibboleth_service_name=$(ask_for_docker_service_and_check "Enter name for shibboleth service : " )

    # Create env files for install
    instance_home_folder="$root_dest/$install_folder_destination"
    run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type_defintion"

    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # # filename - enviroment variables for webserver
    env_shibboleth_file="${absolute_dir}shibboleth"
    env_ldap_file="${absolute_dir}ldap"

    shibboleth_container_name=$(get_environment_value_from_file_by_env_name "${env_shibboleth_file}" "SHIBBOLETH_CONTAINER_NAME")
    # open_ldap_port=$(get_environment_value_from_file_by_env_name "${env_shibboleth_file}" "PORT")

    # # Checks to see if port is being used by something else and ask for a different port for openLDAP
    # check_if_port_is_being_used "$shibboleth_port" "$env_shibboleth_file" "shibboleth"

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

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    local_path_to_mongo_dir="LOCAL_PATH_TO_MONGODB_DIR=$full_daacs_install_defaults_path_to_docker"
    env_dir="ENV_DIR=$absolute_dir"

    env_string="${env_dir}"

    run_docker_with_envs "$shibboleth_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$shibboleth_service_name" "$services_file_dir/$shibboleth_service_name"

}




update_web_instance_helper(){

echo "hello"
}