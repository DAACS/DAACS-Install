#!/bin/bash

source "$current_dir/instance_helpers/basic.sh"
# SHIBBOLETH_IMAGE_NAME="shibbolethreal"
MY_DOCKER_NETWORK_NAME="myNetwork"


: '


ldapsearch -x -H ldap://172.16.215.134:3897 -b "dc=daacs,dc=net" -D "cn=admin,dc=daacs,dc=net"  -w admin "uid=vmckenzie.admin"
ldapsearch -x -H ldap://172.16.215.134:3897 -b "dc=daacs,dc=net" -D "cn=admin,dc=daacs,dc=net"  -w admin "uid=vmckenzie.admin"
ldapsearch -x -H ldaps://172.16.215.134:6363 -b "dc=daacs,dc=net" -D "cn=admin,dc=daacs,dc=net"  -w gOCbKyFW304U9MZV  -o TLS_CACERT=/home/moo/DAACS-Install/new-env-setups/lpadcomplete/mine/ca.crt -o TLS_REQCERT=allow -o TLS_CERT=/home/moo/DAACS-Install/new-env-setups/lpadcomplete/mine/cert.crt -o TLS_KEY=/home/moo/DAACS-Install/new-env-setups/lpadcomplete/mine/cert.key -v   objectclass=*


'

ldap_instance_helper(){

    instance_type="${1}"
    install_env_path="${2}"
    environment_type="${3}"
    install_root="${4}"

    printf "\nShibboleth IDP instance....\n"

    base_path_folder_destination=$(ask_read_question_or_try_again "Enter absolute path destination for install of DAACS: " true)
    install_folder_destination=$(ask_read_question_or_try_again "Enter folder destination for install of DAACS: " true)
    new_or_update=$(ask_read_question_or_try_again "(NLD)New LDAP or (ULD) Update LDAP (SEED) Seed database (CERTS) Generate new certs: " true)

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

    "CERTS")
        generate_new_ssl_for_ldap
    ;;
    *)
        echo "Invalid option"
    ;;
    esac
}

create_ldap_helper(){

    instance_type_defintion=$(get_instance_type_definition "$instance_type")
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
    open_ldap_tls=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "OPENLDAP_BOOTSTRAP_TLS")

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

     case "$(get_env_value $open_ldap_tls)" in
        "true") 

            # Create SSL certs in folder $instance_home_folder/ssl
            save_file_directory_ldap="${instance_home_folder}/ssl"
            save_file_directory_mine="${instance_home_folder}/mine"
            generate_ssl_for_ldap $save_file_directory_ldap $save_file_directory_mine
            
            folder_start_env="FOLDER_START=$instance_home_folder"
            
        ;;
    esac

echo "WOOF"

    # todo - copy ldif folder into $install_root/new-env-setups/$install_folder_destination/ldif/
    folder_start_ldif_dir="FOLDER_START_LDIF=$install_root/new-env-setups/$install_folder_destination/ldif/" # new 
    # folder_start_ldif_dir="FOLDER_START_LDIF=$install_env_path/${instance_type_defintion}/ldif/"   # old 

    env_dir="ENV_DIR=$absolute_dir"
    env_string="${env_dir} ${open_ldap_port} ${open_ldap_ssl_port} ${folder_start_env} ${ldap_base_dn} ${ldap_container_name} ${folder_start_ldif_dir}"


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

    # ldap_container_name=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_CONTAINER_NAME")
    # open_ldap_port=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "PORT")


    ldap_container_name=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_CONTAINER_NAME")
    open_ldap_port=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "PORT")
    ldap_base_dn=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_BASE_DN")
    open_ldap_ssl_port=$(get_environment_value_from_file_by_env_name "${env_ldap_file}" "SSL_PORT")



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
    folder_start_ldif_dir="FOLDER_START_LDIF=$install_root/new-env-setups/$install_folder_destination/ldif/" # new 
    # folder_start_ldif_dir="FOLDER_START_LDIF=$install_env_path/${instance_type_defintion}/ldif/"   # old 
    env_dir="ENV_DIR=$absolute_dir"
    folder_start_env="FOLDER_START=$instance_home_folder"

    env_string="${env_dir} ${open_ldap_port} ${open_ldap_ssl_port} ${folder_start_env} ${ldap_base_dn} ${ldap_container_name} ${folder_start_ldif_dir}"

echo $env_string
    run_docker_with_envs "$ldap_docker_file_to" "$env_string ${folder_start_ldif_dir}"



    services_file_dir="$root_dest/$install_folder_destination/services"
    for entry in "$services_file_dir"/*
    do
        update_services_ids_in_service_file "$entry"
    done
    
}



generate_new_ssl_for_ldap(){

    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    printf "\nCREATING LDAP instance....\n"
 
    env_to_create=$(get_env_files_for_editing $instance_type $install_env_path $environment_type)
    environment_type_defintion=$(get_env_type_definition "$environment_type")
    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    # ldap_service_name=$(ask_for_docker_service_and_check "Enter name for ldap service : " )

    # Create env files for install
    instance_home_folder="$root_dest/$install_folder_destination"
    # run_fillout_program_new "$env_to_create" "$instance_home_folder" "$environment_type_defintion"

    # create_directory_if_it_does_exsist "$root_dest/$install_folder_destination/docker/"
   # Create SSL certs in folder $instance_home_folder/ssl


    save_file_directory_ldap="${instance_home_folder}/ssl"
    save_file_directory_mine="${instance_home_folder}/mine"
    generate_ssl_for_ldap $save_file_directory_ldap $save_file_directory_mine
    

}

seed_ldap_database(){

    environment_type_defintion=$(get_env_type_definition "$environment_type")
    instance_type_defintion=$(get_instance_type_definition "$instance_type")
    ldif_seed_dir="$install_env_path/${instance_type_defintion}/ldif/"

    ldap_service_name=$(ask_read_question_or_try_again "What LDAP container name?: " true)
    service_ID=$(get_services_ids_by_service_name "$ldap_service_name")

    root_dest="$install_root/new-env-setups"
    absolute_dir="$root_dest/$install_folder_destination/$environment_type_defintion/$environment_type_defintion-"
    env_ldap_file="${absolute_dir}ldap"
    should_write_env_passwords="false"

    dc_suffix=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "OPENLDAP_BOOTSTRAP_SUFFIX"))
    ldap_admin_password=$(get_env_value $(get_environment_value_from_file_by_env_name "${env_ldap_file}" "LDAP_ADMIN_PASSWORD"))
    
    if [ "$ldap_admin_password" == "" ]; then 
        ldap_admin_password=$(ask_read_question_or_try_again "What LDAP admin password?: " true)
        append_to_file "LDAP_ADMIN_PASSWORD=${ldap_admin_password}\r" "${env_ldap_file}"
    fi 

    
    # if not production then ask
    case "$environment_type_defintion" in
        "env-dev") 
           should_ssl_connect=$(ask_read_question_or_try_again "SSL Connect?: " true)

        ;;
        "env-prod") 

            # if [ "$password" == "" ]; then 
            #     ldap_admin_password=$(ask_read_question_or_try_again "What LDAP admin password?: " true)
            #     append_to_file "LDAP_ADMIN_PASSWORD=${ldap_admin_password}\r" "${env_ldap_file}"
            # fi 

            should_ssl_connect=true

        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac

    # conf_files=("configs/memberof.ldif")
    files=()
    
    case "$environment_type_defintion" in
        "env-dev") 
            files+=("groups/ou/group.ldif" "groups/ou/development.ldif")
        ;;
        "env-prod") 
            files+=("groups/ou/group.ldif" "groups/ou/production.ldif")
        ;;
        *)
            echo "Invalid instance option"
            exit -1
        ;;
    esac
    
    files+=("users/user-victor.ldif" "users/user-angela.ldif" "users/user-elie.ldif" "users/user-jason.ldif")
    files+=("groups/groupofnames/daacs.ldif" "groups/groupofnames/jenkins.ldif" )
    commands=""
    for i in "${files[@]}"; do  
        catted=""

        case "$environment_type_defintion" in
            "env-dev") 
                catted="ldapadd -x -H ldap://localhost:3890 -D \"cn=admin,${dc_suffix}\" -w ${ldap_admin_password} -f /container/services/openldap/assets/ldif/${i}"
            
            ;;
            "env-prod") 
                catted="ldapadd -x -H ldaps://localhost:6360 -D \"cn=admin,${dc_suffix}\" -w ${ldap_admin_password}  -o TLS_CACERT=/container/services/openldap/assets/certs/ca.crt -o TLS_REQCERT=allow -o TLS_CERT=/container/services/openldap/assets/certs/cert.crt -o TLS_KEY=/container/services/openldap/assets/certs/cert.key -f /container/services/openldap/asset/ldif/${i} "
            
            ;;
        esac

        beginnig_exec="docker exec -it ${service_ID} sh -c  \"${catted}\" "

        if [ ${i} != "${files[-1]}" ]; then
            commands+="$beginnig_exec && "
            else 
            commands+="$beginnig_exec"

        fi 

    done

    eval $commands


}

generate_ssl_for_ldap(){
    # https://docs.openssl.org/master/man1/openssl-req/#options

    save_file_directory_ldap="${1}"
    save_file_directory_mine="${2}"
        
    create_directory_if_it_does_exsist  "${save_file_directory_ldap}"
    create_directory_if_it_does_exsist  "${save_file_directory_mine}"

    openssl genrsa -out "${save_file_directory_ldap}/ca.key" 2048
    openssl req -x509 -new -nodes -key "${save_file_directory_ldap}/ca.key" -sha256 -days 1825 -out "${save_file_directory_ldap}/ca.crt" -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=ldap-server.daacs.net/emailAddress=admin@daacs.net"

    openssl genrsa -out "${save_file_directory_ldap}/cert.key" 2048
    openssl req -new -key "${save_file_directory_ldap}/cert.key" -out "${save_file_directory_ldap}/cert.csr"  -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=ldap-server.daacs.net/emailAddress=admin@daacs.net" 
    # -copy_extensions copy -addext "subjectAltName=DNS:daacs.net,DNS:ldap-server.daacs.net,DNS:ldapssl"

    openssl x509 -req -in "${save_file_directory_ldap}/cert.csr" -CA "${save_file_directory_ldap}/ca.crt" -CAkey "${save_file_directory_ldap}/ca.key" -CAcreateserial -out "${save_file_directory_ldap}/cert.crt" -days 825 -sha256 -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=ldap-server.daacs.net/emailAddress=admin@daacs.net"
    #  -copy_extensions copy -addext "subjectAltName=DNS:daacs.net,DNS:ldap-server.daacs.net,DNS:ldapssl"

    openssl dhparam -dsaparam  -out "${save_file_directory_ldap}/dhparam.pem" 4096
    
    # copy ssl directory to mine that works for me
    sudo cp -R ${save_file_directory_ldap}/*  ${save_file_directory_mine}
    sudo chown $who_ami_i:$who_ami_i ${save_file_directory_mine}/*

    # # change owner:group to 911:911
    sudo chown 911:911 ${save_file_directory_ldap}/*

}