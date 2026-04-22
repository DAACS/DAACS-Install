#!/bin/bash

cd /home/
# Root Certificate

openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt  -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=web server/emailAddress=admin@daacs.net"


# # # # Generate and Sign the Server Certificate 
openssl genrsa -out mongodb.key 2048
openssl req -new -key mongodb.key -out mongodb.csr -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=web server/emailAddress=admin@daacs.net"

openssl x509 -req -in mongodb.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mongodb.crt -days 365 -sha256
# -subj "/C=US/ST=New York/L=Richmond /O=DAACS /OU=Technology /CN=web server/emailAddress=admin@daacs.net"

# # Create Server PEM
cat mongodb.key mongodb.crt > mongodb.pem
# mongod --tlsCertificateKeyFile /home/mongodb.pem --tlsCAFile /home/mongodb.crt --config /home/mongod.conf --tlsAllowInvalidHostnames
mongod --config /home/mongod.conf --tlsAllowInvalidHostnames
