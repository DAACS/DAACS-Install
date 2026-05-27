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
    ldap_base_dn=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_BASE_DN")
    open_ldap_ssl_port=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "SSL_PORT")

    # # Checks to see if port is being used by something else and ask for a different port for openLDAP - todo check to make sure this is working before production
    # check_if_port_is_being_used "$open_ldap_port" "$env_ldap_file" "ldap"

    # if [ $(does_docker_network_exsist "$MY_DOCKER_NETWORK_NAME") = false ]; then
    #     create_docker_network "$MY_DOCKER_NETWORK_NAME"
    # fi

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

     case "$environment_type_defintion" in
        "env-dev") 
            # docker_file="Docker-LDAP-dev.yml"
        ;;
        "env-prod") 

            # Create SSL certs in folder $instance_home_folder/ssl
            save_file_directory_ldap="${instance_home_folder}/ssl"
            save_file_directory_mine="${instance_home_folder}/mine"
            generate_ssl_for_ldap $save_file_directory_ldap $save_file_directory_mine
            
            folder_start_env="FOLDER_START=$instance_home_folder"
            
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

echo "WOOF"

    env_dir="ENV_DIR=$absolute_dir"
    env_string="${env_dir} ${open_ldap_port} ${open_ldap_ssl_port} ${folder_start_env} ${ldap_base_dn} ${ldap_container_name}"


    run_docker_with_envs "$ldap_docker_file_to" "$env_string"
echo "bark"

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
    instance_home_folder="$root_dest/$install_folder_destination"

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
    ldap_admin_password=$(ask_read_question_or_try_again "What LDAP admin password?: " true)
    ldap_config_password=$(ask_read_question_or_try_again "What LDAP config password?: " true)
    should_write_env_passwords=$(ask_read_question_or_try_again "Should write password to env file?: " true)

    # if not production then ask
    should_ssl_connect=$(ask_read_question_or_try_again "SSL Connect?: " true)

    service_ID=$(get_services_ids_by_service_name "$ldap_service_name")
    # service_ID="704c1c5cafd5"
     

    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    env_ldap_file="${absolute_dir}ldap"

    dc_suffix=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "OPENLDAP_BOOTSTRAP_SUFFIX"))

    # Write passwords to ENV Files
    # ld_admin_password=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_ADMIN_PASSWORD"))
    # ld_conf_password=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_CONFIG_PASSWORD"))

    # conf_files=("configs/memberof.ldif")
    files=()
    
    # case "$environment_type_defintion" in
    #     "env-dev") 
    #         files+=("groups/ou/group.ldif" "groups/ou/development.ldif")
    #     ;;
    #     "env-prod") 
    #         files+=("groups/ou/group.ldif" "groups/ou/production.ldif")
    #     ;;
    #     *)
    #         echo "Invalid instance option"
    #         exit -1
    #     ;;
    # esac
    
    files+=("users/user-victor.ldif" "users/user-angela.ldif" "users/user-elie.ldif" "users/user-jason.ldif")
    files+=("groups/groupofnames/daacs.ldif" "groups/groupofnames/jenkins.ldif" )

    commands=""

    for i in "${conf_files[@]}"; do  
        catted="ldapadd -x -H ldap://localhost:3890 -D \"cn=admin,cn=config\" -w ${ld_conf_password} -f /ldif/${i}"
        beginnig_exec="docker exec -it ${service_ID} sh -c  \"${catted}\""

        echo $i
        echo "${conf_files[-1]}"

        if [ ${i} != "${conf_files[-1]}" ]; then
            commands+="$beginnig_exec && "
            else 
            commands+="$beginnig_exec"

        fi 

        eval $beginnig_exec
        break

    done
    eval $commands

    commands=""
    for i in "${files[@]}"; do  
        catted="ldapadd -x -H ldap://localhost:3890 -D \"cn=admin,${dc_suffix}\" -w ${ld_admin_password} -f /ldif/${i}"
        beginnig_exec="docker exec -it ${service_ID} sh -c  \"${catted}\" "
        # echo "${i}"
        # echo "${files[-1]}"

        if [ ${i} != "${files[-1]}" ]; then
            commands+="$beginnig_exec && "
            else 
            commands+="$beginnig_exec"

        fi 
    done
    eval $commands

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

}

generate_ssl_for_ldap(){

    save_file_directory_ldap="${1}"
    save_file_directory_mine="${2}"
        
    create_directory_if_it_does_exsist  "${save_file_directory_ldap}"
    create_directory_if_it_does_exsist  "${save_file_directory_mine}"

    openssl genrsa -out "${save_file_directory_ldap}/ca.key" 2048
    openssl req -x509 -new -nodes -key "${save_file_directory_ldap}/ca.key" -sha256 -days 1825 -out "${save_file_directory_ldap}/ca.crt" -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=ldap-server.daacs.net/emailAddress=admin@daacs.net"

    openssl genrsa -out "${save_file_directory_ldap}/server.key" 2048
    openssl req -new -key "${save_file_directory_ldap}/server.key" -out "${save_file_directory_ldap}/server.csr" -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=ldap-server.daacs.net/emailAddress=admin@daacs.net"
    openssl x509 -req -in "${save_file_directory_ldap}/server.csr" -CA "${save_file_directory_ldap}/ca.crt" -CAkey "${save_file_directory_ldap}/ca.key" -CAcreateserial -out "${save_file_directory_ldap}/server.crt" -days 825 -sha256 -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=ldap-server.daacs.net/emailAddress=admin@daacs.net"
    openssl dhparam -dsaparam  -out "${save_file_directory_ldap}/dhparam.pem" 4096
    
    # copy ssl directory to mine that works for me
    sudo cp -R ${save_file_directory_ldap}/*  ${save_file_directory_mine}
    sudo chown $who_ami_i:$who_ami_i ${save_file_directory_mine}/*

    # # change owner:group to 911:911
    sudo chown 911:911 ${save_file_directory_ldap}/*

}