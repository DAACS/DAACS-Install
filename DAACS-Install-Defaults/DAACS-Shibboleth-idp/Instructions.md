How to build and run Shibboleth IDP container 
# cd /home/moo/DAACS-Install/DAACS-Install-Defaults/DAACS-Shibboleth-idp/Docker-idp-build && 

# docker build -t shib521 -f /home/moo/DAACS-Install/DAACS-Install-Defaults/DAACS-Shibboleth-idp/Docker-idp-build .

see how I can get ENV into idp.properties so they can be read from what i set when I Create the contianer



ldap.properties needs to have dynamic ENV read from when I create container 

dev
idp.authn.LDAP.ldapURL                          = ldap://172.16.215.134:389
idp.authn.LDAP.useStartTLS                     = false
idp.authn.LDAP.useSSL                           = false
idp.authn.LDAP.baseDN                           = dc=example,dc=org
idp.authn.LDAP.bindDN                           = cn=admin,dc=example,dc=org
idp.authn.LDAP.bindDNCredential                  = admin
idp.authn.LDAP.dnFormat                         = uid=%s,dc=example,dc=org


prod

idp.authn.LDAP.ldapURL                          = ldap://172.16.215.134:389
idp.authn.LDAP.useStartTLS                     = true
idp.authn.LDAP.useSSL                           = true
idp.authn.LDAP.baseDN                           = dc=daacs,dc=net
idp.authn.LDAP.bindDN                           = cn=(change to real admin username),dc=daacs,dc=net
idp.authn.LDAP.bindDNCredential                  = change to real admin username
idp.authn.LDAP.dnFormat                         = uid=%s,dc=daacs,dc=net





copy these files from conf/

attribute-filter.xml
attribute-resolver.xml

update these files 
ldap.properties
metadata-providers.xml - add MetadataProvider with metadat from each instance 
relying-party.xml - add new line for each instance bean id="ExampleSP4" parent="RelyingPartyByName" c:relyingPartyIds="https://yogurt.victor.com"

copy these files from jetty-conf/
update these files for jetty
/var/lib/jetty/start.d/http.ini 
jetty.http.port=80

copy these files from jetty-base/
/var/lib/jetty/webapps/root/index.html
/var/lib/jetty/webapps/idp.xml

copy these files from views/

/opt/shibboleth-idp/views/
