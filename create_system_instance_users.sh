#!/bin/bash 

function check_if_dir_exsist(){

  if test -d $1; then
    echo true
  fi
}

function change_users_main_group(){
   usermod -g $1 $2
}

function create_user_and_save_keys(){
  #$1 - username
  
  USERNAME=$1
  myBaseDir="/home/$USERNAME"
  useradd -m -d $myBaseDir $USERNAME -G docker,sudo,root
  mkdir "$myBaseDir/.ssh"
  touch "$myBaseDir/.ssh/authorized_keys"
  ssh-keygen -t ed25519 -f $USERNAME -f "$myBaseDir/.ssh/${USERNAME}_rsa" -N ''
  cat "$myBaseDir/.ssh/${USERNAME}_rsa.pub" >> "$myBaseDir/.ssh/authorized_keys" 
  chown "$USERNAME:$USERNAME" "$myBaseDir/.ssh" "$myBaseDir/.ssh/authorized_keys" "$myBaseDir/.ssh/${USERNAME}_rsa.pub" "$myBaseDir/.ssh/${USERNAME}_rsa"
  zipFileName="${USERNAME}_keys.zip"

  cd "$myBaseDir/.ssh" && echo $PWD && ls -l && zip "${zipFileName}" "./${USERNAME}_rsa" "./${USERNAME}_rsa.pub" && mv "${zipFileName}" /root/ && cd /root/


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


  rm "${zipFileName}"
}
: '

$1 - users to create
$2 - instance domain
$3 - digitalocean access token
$4 - digitalocean access secret 
$5 - digitalocean space
$6 - digitalocean region
$7 - web management group

'

read -p "Enter your users comma seperated no spaces. First user is for mantanice, second is for jenkins : " users
read -p "Enter your instance domain ex(www.website.com): " instance
read -p "Enter your digitalocean access token: " accesstoken
read -p "Enter your digitalocean access secret: " accesssecret
read -p "Enter your digitalocean space: " space
read -p "Enter your digitalocean access region: " region
read -p "Web management group: " groups_name

# create web directories
mkdir -p /var/www/html

# # #create Web manangement group
groupadd -f ${groups_name}

# # Split the string by comma and store the result in an array
IFS=',' read -ra ADDR <<< "$users"

# # Print each element of the array
for i in "${ADDR[@]}"; do
  create_user_and_save_keys "$i"
  send_keys_to_digitalocean "$i" "$instance" "$accesstoken" "$accesssecret" "$space" "$region"
  change_users_main_group  "$groups_name" "$i"

done

# #I need to change chown /var/www/html to jenkinscdci:webmanagement 
chown -R "${ADDR[0]}":${groups_name} /var/www