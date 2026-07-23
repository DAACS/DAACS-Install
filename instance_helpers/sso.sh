#!/bin/bash

source "$current_dir/instance_helpers/basic.sh"
SHIBBOLETH_IMAGE_NAME="shibbolethreal"
MY_DOCKER_NETWORK_NAME="myNetwork"
SHIB_FOLDER_SERVICE_NAME="shibreset"

: '


/opt/shibboleth-idp/bin/aacli.sh --principal vmckenzie --requester https://yogurt.victor.com/
/opt/shibboleth-idp/bin/aacli.sh --principal winstonhong --requester https://yogurt.victor.com
/opt/shibboleth-idp/bin/reload-service.sh -id shibboleth.AttributeResolverService
/opt/shibboleth-idp/bin/aacli.sh --principal vmckenzie.admin --requester https://yogurt.victor.com/

/opt/shibboleth-idp/bin/reload-service.sh -id shibboleth.RelyingPartyResolverService
'

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
 
    # env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    # environment_type_defintion=$(get_env_type_definition "$environment_type")
    # shibboleth_service_name=$(ask_for_docker_service_and_check "Enter name for shibboleth service : " )
    # ldap_service_directory=$(ask_read_question_or_try_again "Enter folder directory for LDAP envs: " true)
    # should_create_reset_server=$(ask_read_question_or_try_again "Should create reset password server (y) : " true)


    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    shibboleth_service_name="shibwithreset2"
    ldap_service_directory="ldaplysol"
    should_create_reset_server="y"


    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    absolute_dir_for_ldap="$root_dest/$ldap_service_directory/$environment_type_defintion/$environment_type_defintion-"
    instance_home_folder="$root_dest/$install_folder_destination"
        
#     # Create env files for install
    # run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type_defintion"

    # create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # # filename - enviroment variables for webserver
    env_shibboleth_file="${absolute_dir}shibboleth"
    env_ldap_file="${absolute_dir_for_ldap}"

    shibboleth_container_name=$(get_environment_value_from_file_by_env_name "${env_shibboleth_file}" "SHIBBOLETH_CONTAINER_NAME")
    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    env_shib_reset_virtual_host=""
    if [ "$should_create_reset_server" = "y" ]; then

        env_shib_reset_virtual_host_value=$(do_ldap_reset_service )
        env_shib_reset_virtual_host_value=$(get_env_value "$env_shib_reset_virtual_host_value")
        env_shib_reset_virtual_host="ENV_LDAP_RESTART_VIRTUAL_HOST=$env_shib_reset_virtual_host_value"
        echo $env_shib_reset_virtual_host
    fi

# echo $env_shib_reset_virtual_host
# echo $(get_env_value "$env_shib_reset_virtual_host")
# exit 1

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
    env_string="${env_dir} ${env_ldap_file} ${env_shib_reset_virtual_host}"

# echo $env_string 
# exit 1
    run_docker_with_envs "$shibboleth_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$shibboleth_service_name" "$services_file_dir/$shibboleth_service_name"
    write_ldap_config_file "$absolute_dir" "$ldap_service_directory" "$shibboleth_service_name"

}

update_web_idp_helper(){

  printf "\nUPDATING Shibboleth IDP server instance....\n"

    should_update_envs=$(ask_read_question_or_try_again "Should I update envs? (y)es or (n)o: " true) 
    root_dest="$install_root/new-env-setups"
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    
    absolute_dir_for_ldap_config_file="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-/database-config/$install_folder_destination"

    ldap_folder=$(get_environment_value_from_file_by_env_name "$absolute_dir_for_ldap_config_file" "LDAP_DB_DIRECTORY") 
    # mongo_database_directory=$(get_environment_value_from_file_by_env_name "$absolute_dir_for_ldap_config_file" "DATABASE_NAME") 
    absolute_dir_for_ldap_ssl="$root_dest/$(get_env_value "$ldap_folder" )/$(get_env_value "$ldap_folder" )" # i need to check to make sure this works
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
    #todo -  if there is a reset service then we should restart that too

    ldap_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )

    env_dir="ENV_DIR=$absolute_dir"
    env_ldap_file="ENV_LDAP_DIR=$absolute_dir_for_ldap"
    env_ldap_ssl_file="ENV_LDAP_SSL_DIR=$absolute_dir_for_ldap_ssl"
 
    env_string="${env_dir} ${env_ldap_file} ${env_ldap_ssl_file}"
    run_docker_with_envs "$ldap_docker_file_to" "$env_string"

    # services_file_dir="$root_dest/$install_folder_destination/services"
    # for entry in "$services_file_dir"/*
    # do
    #     update_services_ids_in_service_file "$entry"
    # done
}

write_ldap_config_file(){

    destdir="${1}/database-config/"
    create_directory_if_it_does_exsist "$destdir"
    database_config_env="LDAP_DB_DIRECTORY=${2}"
    write_to_file "$database_config_env" "$destdir/$"
}


do_ldap_reset_service(){

    root_dest="$install_root/new-env-setups"
    # shibboleth_reset_service_name=$(ask_for_docker_service_and_check "Enter name for shibboleth reset service : " )
    shibboleth_reset_service_name="ldapresetreal"
    resetshib_instance_type_defintion=$(get_instance_type_definition "10")    
    
    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # env_to_create_for_reset_server=$(get_env_files_for_editing "10" $install_env_path $environment_type)
    # run_fillout_program_new "$env_to_create_for_reset_server" "$instance_home_folder/$SHIB_FOLDER_SERVICE_NAME" "$environment_type_defintion"

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-ShibResetserver-dev.docker.yml"
        ;;
        "env-prod") 
            docker_file="Docker-ShibResetserver-prod.docker.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    # # works dont touch
    # run_clone_repo_for_shib_reset "$environment_type" "$base_path_folder_destination" "$shibboleth_reset_service_name" "main"

    # # install node modules for reset shib server
    # get_node_modules "$base_path_folder_destination/$shibboleth_reset_service_name/" 


    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$shibboleth_reset_service_name"

    shibboleth_docker_file_to=$(write_service_subsititions_to_docker_file "$resetshib_instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#shibreset_service_name/$shibboleth_reset_service_name/g ;" $docker_file)
    

    absolute_dir_for_shib_reset="$root_dest/$install_folder_destination/$SHIB_FOLDER_SERVICE_NAME/$environment_type_defintion/$environment_type_defintion-"
    # absolute_dir_for_ldap="$root_dest/$ldap_service_directory/$environment_type_defintion/$environment_type_defintion-"
    # folder_start_env="FOLDER_START=$absolute_path_to_path_to_project_directory"
    # env_dir="ENV_DIR=$absolute_dir_for_shib_reset"
    # env_ldap_file="ENV_DIR_TO_LDAP=$absolute_dir_for_ldap"

    # env_ldap_root=$(get_environment_value_from_file_by_env_name "${absolute_dir_for_shib_reset}sso-reset" "LDAP_ROOT")
    # env_open_ldap_bootstrap_suffix=$(get_environment_value_from_file_by_env_name "${absolute_dir_for_ldap}ldap" "OPENLDAP_BOOTSTRAP_SUFFIX")
    # env_string="${env_dir} ${env_ldap_file} ${folder_start_env} ${env_ldap_root} ${env_open_ldap_bootstrap_suffix}"

    # run_docker_with_envs "$shibboleth_docker_file_to" "$env_string"

    # services_file_dir="$root_dest/$install_folder_destination/services"
    # mkdir -p "$services_file_dir"
    # add_services_service_file "$shibboleth_service_name" "$services_file_dir/$shibboleth_service_name"
    # write_ldap_config_file "$absolute_dir" "$ldap_service_directory" "$shibboleth_service_name"
    env_virtual_host=$(get_environment_value_from_file_by_env_name "${absolute_dir_for_shib_reset}sso-reset" "VIRTUAL_HOST")
    echo "$env_virtual_host"
}

run_clone_repo_for_shib_reset(){

    # ${1}=environment_type
    # ${2}=base_path_folder_destination
    # ${3}=install_folder_destination
    # ${4}=branch

        # # # # get code from repo
    if [ "${1}" = "prod" ]; then
        clone_repo "${2}" "${3}" "git@github.com:DAACS/DAACSLDAPWebserver.git" "${4}"
    fi

    if [ "${1}" = "dev" ]; then
        clone_repo "${2}" "${3}" "git@github.com:DAACS/DAACSLDAPWebserver.git" "${4}"
    fi
}