#!/usr/bin/env bash

# RUN $IDP_SRC/bin/install.sh --propertyFile /tmp/idp-install.properties
# RUN rm shibboleth-identity-provider-$idp_version.tar \
#     && rm -rf /opt/shibboleth-identity-provider-$idp_version



RUN $IDP_SRC/bin/install.sh --propertyFile /tmp/idp-install.properties
RUN rm $IDP_SRC.tar \
    && rm -rf $IDP_SRC




exec "$@"