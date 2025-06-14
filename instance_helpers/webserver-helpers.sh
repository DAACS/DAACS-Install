


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