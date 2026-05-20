#!/bin/bash

source "$current_dir/instance_helpers/basic.sh"
# SHIBBOLETH_IMAGE_NAME="shibbolethreal"
MY_DOCKER_NETWORK_NAME="myNetwork"

ldap_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nShibboleth IDP instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    new_or_update=$(ask_read_question_or_try_again "(NLD)New LDAP or (ULD) Update LDAP (SEED) Seed database: " true)

    case "$new_or_update" in
    "NLD") 
        create_ldap_helper 
    ;;

    "ULD") 
        # does_dir_exist=$(does_dir_exsist "$base_path_folder_destination/$install_folder_destination")
        does_dir_env=$(does_dir_exsist "$install_root/new-env-setups/$install_folder_destination")

        if [[ $does_dir_env == true ]]; then
            update_ldap_instance_helper
        else
            echo "Is env missing: $does_dir_env"
        fi
    ;;

    "SEED")
        seed_ldap_database
    ;;
    *)
        echo "Invalid option"
    ;;
    esac
}




create_ldap_helper(){

    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    
    # build_file="Docker-idp-build-dev"
    # shibboleth_files_to="$install_env_path/${instance_type_defintion}/docker/${build_file}"
    # create_image "$shibboleth_files_to" "${SHIBBOLETH_IMAGE_NAME}" "$install_env_path/${instance_type_defintion}/docker/" 

    printf "\nCREATING LDAP instance....\n"
 
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    ldap_service_name=$(ask_for_docker_service_and_check "Enter name for ldap service : " )

    # Create env files for install
    instance_home_folder="$root_dest/$install_folder_destination"
    run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type_defintion"

    create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"

    # # filename - enviroment variables for webserver
    env_ldap_file="${absolute_dir}ldap"

    ldap_container_name=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_CONTAINER_NAME")
    open_ldap_port=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "PORT")

    # # Checks to see if port is being used by something else and ask for a different port for openLDAP - todo check to make sure this is working before production
    # check_if_port_is_being_used "$open_ldap_port" "$env_ldap_file" "ldap"

    if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
        create_docker_network "$MY_DOCKER_NETWORK_NAME"
    fi

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-LDAP-dev.yml"
        ;;
        "env-prod") 
            docker_file="Docker-LDAP-prod.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    ldap_docker_file_to=$(write_service_subsititions_to_docker_file "$instance_type_defintion" "$install_folder_destination" "$install_env_path" "$environment_type_defintion" "s/#ldap_service_name/$ldap_service_name/g ;" $docker_file)

    absolute_path_to_path_to_project_directory="$base_path_folder_destination/$install_folder_destination"

    full_daacs_install_defaults_path="$install_env_path/$instance_type_defintion"
    full_daacs_install_defaults_path_to_docker="$full_daacs_install_defaults_path/docker/mongodb"

    env_dir="ENV_DIR=$absolute_dir"
    env_string="${env_dir} ${open_ldap_port}"

    run_docker_with_envs "$ldap_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    mkdir -p "$services_file_dir"
    add_services_service_file "$ldap_service_name" "$services_file_dir/$ldap_service_name"

}


update_ldap_instance_helper(){
  
    printf "\nUpdating LDAP instance....\n"

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

    # enviroment variables for webserver
    env_ldap_file="${absolute_dir}ldap"


    ldap_container_name=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_CONTAINER_NAME")
    open_ldap_port=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "PORT")

    docker_file=""

    case "$environment_type_defintion" in
        "env-dev") 
            docker_file="Docker-LDAP-dev.yml"
        ;;
        "env-prod") 
            docker_file="Docker-LDAP-prod.yml"
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    ldap_docker_file_to=$(generate_docker_file_path "to" "$install_folder_destination" "$docker_file" "$install_env_path" "$instance_type_defintion" )
    env_dir="ENV_DIR=$absolute_dir"
    env_string="${env_dir} ${open_ldap_port}"

    run_docker_with_envs "$ldap_docker_file_to" "$env_string"

    services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done
    
}


seed_ldap_database(){

    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    ldif_seed_dir="$install_env_path/${instance_type_defintion}/ldif/"
    ldap_service_name=$(ask_read_question_or_try_again "What LDAP container name?: " true)


    service_ID=$(get_services_ids_by_service_name "$ldap_service_name")
    service_ID=$(echo "$service_ID" | tr -d " " )

    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    env_ldap_file="${absolute_dir}ldap"

    dc_suffix=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "OPENLDAP_BOOTSTRAP_SUFFIX"))
    port=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "PORT"))
    ld_admin_password=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_ADMIN_PASSWORD"))
    ld_conf_password=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_CONFIG_PASSWORD"))

    conf_files=("configs/memberof.ldif")
    files=("groups/ou/group.ldif" "groups/ou/development.ldif")
    files+=("users/user-victor.ldif" "users/user-angela.ldif" "users/user-elie.ldif" "users/user-jason.ldif")
    files+=("groups/groupofnames/daacs.ldif" "groups/groupofnames/jenkins.ldif" )


    for i in "${conf_files[@]}"; do  
        catted="ldapadd -x -H ldap://localhost:389 -D \"cn=admin,cn=config\" -w ${ld_conf_password} -f /ldif/${i}"
        beginnig_exec="docker exec -it ${service_ID} sh -c  \"${catted}\""

        eval $beginnig_exec
        break

    done

    commands=""
    for i in "${files[@]}"; do  
        catted="ldapadd -x -H ldap://localhost:389 -D \"cn=admin,${dc_suffix}\" -w ${ld_admin_password} -f /ldif/${i}"
        beginnig_exec="docker exec -it ${service_ID} sh -c  \"${catted}\" "
        echo "${i}"
        echo "${files[-1]}"

        if [ ${i} != "${files[-1]}" ]; then
            commands+="$beginnig_exec && "
            else 
            commands+="$beginnig_exec"

        fi 
    done

    commands=""

    for i in "${files[@]}"; do  
        catted="ldapadd -x -H ldap://localhost:389 -D \"cn=admin,${dc_suffix}\" -w ${ld_admin_password} -f /ldif/${i}"
        beginnig_exec="docker exec -it ${service_ID} sh -c  \"${catted}\" "
        echo "${i}"
        echo "${files[-1]}"

        if [ ${i} != "${files[-1]}" ]; then
            commands+="$beginnig_exec && "
            else 
            commands+="$beginnig_exec"

        fi 
    done

    eval $commands
    echo $commands

    
    # eval "$catted"

    # # ldapadd  -x -H ldap://172.20.0.2:389 -D "cn=admin,dc=daacs,dc=net" -w admin -f development.ldif
    # # ldapadd  -x -H ldap://172.20.0.2:389 -D "cn=admin,dc=daacs,dc=net" -w admin -f user-victor.ldif
    # # ldapadd  -x -H ldap://172.20.0.2:389 -D "cn=admin,dc=daacs,dc=net" -w admin -f user-angela.ldif
    # # ldapadd  -x -H ldap://172.20.0.2:389 -D "cn=admin,dc=daacs,dc=net" -w admin -f groups/group.ldif
    # # ldapadd  -x -H ldap://172.20.0.2:389 -D "cn=admin,dc=daacs,dc=net" -w admin -f groups/create-daacs-group-of-names.ldif


}