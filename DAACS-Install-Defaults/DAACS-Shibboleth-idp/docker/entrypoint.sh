#!/bin/bash

echo $(cd /opt/shibboleth-idp/bin/ && ls -l)

$IDP_SRC/bin/install.sh --entityID $ENTITY_ID --targetDir $JETTY_BASE/webapps --hostName $VIRTUAL_HOST --scope $SHIBBOLETH_SCOPE && mv $JETTY_BASE/webapps/war/idp.war $JETTY_BASE/webapps/idp.war
exec "$@"