openldap install

docker build
docker compose

create top level DN

cat data.ldif
dn: dc=fedji,dc=com objectclass: dcObject objectclass: Organization
o: Fedji dc: fedji
ldapadd -D cn="Manager,dc=fedji,dc=com" -w secret -f d
ata.ldif_
adding new entry dc=fedji,dc=com


ldapsearch -D cn="Manager,dc=fedji,dc=com"
-w secret -
b dc=fedji,dc=com objectclass=*