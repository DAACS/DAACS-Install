#!/bin/bash 

user_data_dir="$current_dir/user-data"

function check_if_dir_exsist(){

  if test -d $1; then
    echo true
  fi
}

function change_users_main_group(){
   usermod -g $1 $2
}


function check_if_sudo_is_in_group(){

  groups="$1"
  IFS=',' read -ra ADDR <<< "$groups"

  has_sudo=false
  for i in "${ADDR[@]}"; do
    #   echo "$i"
    
    if [ "$i" = "sudo" ]; then
      has_sudo=true
      break;
    fi
  done

  echo "$has_sudo"
}

function create_user(){
  
  instance="$1" 
  accesstoken="$2" 
  accesssecret="$3"
  space="$4"
  region="$5"
  USERNAME="$6" 
  groups="$7"

  myBaseDir="/home/$USERNAME"
  group_add=""
  is_sudo=false

  if [ "$groups" != "" ]; then
    group_add="-G $groups"
    is_sudo=$(check_if_sudo_is_in_group "$groups")
  fi

  useradd -m -d $myBaseDir $USERNAME $group_add

  mkdir "$myBaseDir/.ssh"
  touch "$myBaseDir/.ssh/authorized_keys"
  ssh-keygen -t ed25519 -f $USERNAME -f "$myBaseDir/.ssh/${USERNAME}_rsa" -N ''
  cat "$myBaseDir/.ssh/${USERNAME}_rsa.pub" >> "$myBaseDir/.ssh/authorized_keys" 
  chown "$USERNAME:$USERNAME" "$myBaseDir/.ssh" "$myBaseDir/.ssh/authorized_keys" "$myBaseDir/.ssh/${USERNAME}_rsa.pub" "$myBaseDir/.ssh/${USERNAME}_rsa"
  zipFileName="${USERNAME}_keys.zip"

  cd "$myBaseDir/.ssh" && echo $PWD && ls -l && zip "${zipFileName}" "./${USERNAME}_rsa" "./${USERNAME}_rsa.pub" && mv "${zipFileName}" "$user_data_dir"

  #add this only for sudo group users
  if [ "$is_sudo" == true ]; then
      echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi

  send_keys_to_digitalocean "$USERNAME" "$instance"  "$accesstoken" "$accesssecret" "$space" "$region"

}



function send_keys_to_digitalocean(){
  #$1 - username
  #$2 - instance domain
  #$3 - digitalocean access token 
  #$4 - digitalocean access secret
  #$5 - digitalocean space
  #$6 - digitalocean region

  USERNAME=$1
  zipFileName="${USERNAME}_keys.zip"
  cd "$user_data_dir"
  # Step 1: Define the parameters for the Space you want to upload to.
  SPACE="$5" # Find your endpoint in the control panel, under Settings.
  REGION="$6" # Must be "us-east-1" when creating new Spaces. Otherwise, use the region in your endpoint (for example, nyc3).
  STORAGETYPE="STANDARD" # Storage type, can be STANDARD, REDUCED_REDUNDANCY, etc.
  KEY="$3" # Access key pair. You can create access key pairs using the control panel or API.
  SECRET="$4" # Secret access key defined through an environment variable.
    file=$zipFileName # The file you want to upload.
    space_path="/$2/" # The path within your Space where you want to upload the new file.
    space=$SPACE
    date=$(date +"%a, %d %b %Y %T %z")
    acl="x-amz-acl:private" # Defines Access-control List (ACL) permissions, such as private or public.
    content_type="text/plain" # Defines the type of content you are uploading.
    storage_type="x-amz-storage-class:${STORAGETYPE}"
    string="PUT\n\n$content_type\n$date\n$acl\n$storage_type\n/$space$space_path$file"
    signature=$(echo -en "${string}" | openssl sha1 -hmac "${SECRET}" -binary | base64)
    curl -s -X PUT -T "$file" \
      -H "Host: $space.${REGION}.digitaloceanspaces.com" \
      -H "Date: $date" \
      -H "Content-Type: $content_type" \
      -H "$storage_type" \
      -H "$acl" \
      -H "Authorization: AWS ${KEY}:$signature" \
      "https://$space.${REGION}.digitaloceanspaces.com$space_path$file"

}
: '

$1 - users to create
$2 - users to create
$3 - instance domain
$4 - digitalocean access token
$5 - digitalocean access secret 
$6 - digitalocean space
$7 - digitalocean region

'

read -p "Enter your users name for mantanice : " users1
read -p "Enter your users groups : " groups
read -p "Enter your instance domain ex(www.website.com): " instance
read -p "Enter your digitalocean access token: " accesstoken
read -p "Enter your digitalocean access secret: " accesssecret
read -p "Enter your digitalocean space: " space
read -p "Enter your digitalocean access region: " region

create_user "$instance" "$accesstoken" "$accesssecret" "$space" "$region" "$users1" "$groups"
