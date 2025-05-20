#!/bin/bash

# cd /home
# openssl req \
# -new \
# -newkey rsa:4096 \
# -days 365 \
# -nodes \
# -x509 \
# -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
# -keyout /home/mongossl.key \
# -out  /home/mongossl.cert

# cat /home/mongossl.key /home/mongossl.cert > /home/mongossl.pem
# mongod --config /home/mongod.conf --replSet myReplicaSet --setParameter tlsUseSystemCA=true 
# mongod --replSet myReplicaSet --setParameter tlsUseSystemCA=true 
mongod