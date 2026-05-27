#!/bin/bash


get_replace(){
    var=$1
    echo "${var%=*}=$2"
}


do_replace(){

    i="$1"
    user_input="$2"
    input_file="$3"

    value2=$(get_replace $i $user_input)
    string_reaplce_in_file_expression="s/${i}/${value2}/g" 
    echo $string_reaplce_in_file_expression
    sed -i -E -e "$string_reaplce_in_file_expression" $input_file
}

set -e

if [ "$1" = jetty.sh ]; then
	if ! command -v bash >/dev/null 2>&1 ; then
		cat >&2 <<- 'EOWARN'
			********************************************************************
			ERROR: bash not found. Use of jetty.sh requires bash.
			********************************************************************
		EOWARN
		exit 1
	fi
	cat >&2 <<- 'EOWARN'
		********************************************************************
		WARNING: Use of jetty.sh from this image is deprecated and may
			 be removed at some point in the future.

			 See the documentation for guidance on extending this image:
			 https://github.com/docker-library/docs/tree/master/jetty
		********************************************************************
	EOWARN
fi

if [ ! -f "/installed" ]; then

	# Add real SLO url - todo its adding SLO but removing SOAP.. do we need SOAP ?
	sed -i -e "s/\<md\:SingleLogoutService Binding=\"urn\:oasis\:names\:tc\:SAML\:2\.0\:bindings\:HTTP\-Redirect\" Location\=\"https\:\/\/idp3\.victor\.com\/idp\/profile\/SAML2\/SOAP\/Redirect\/SLO\" \/\>/\<md\:SingleLogoutService Binding\=\"urn\:oasis\:names\:tc\:SAML\:2\.0\:bindings\:HTTP\-Redirect\" Location\=\"https\:\/\/idp3\.victor\.com\/idp\/profile\/SAML2\/Redirect\/SLO\" \/\> \<md\:SingleLogoutService Binding=\"urn\:oasis\:names\:tc\:SAML\:2\.0\:bindings\:HTTP\-Redirect\" Location\=\"https\:\/\/idp3\.victor\.com\/idp\/profile\/SAML2\/SOAP\/Redirect\/SLO\" \/\>/g" $IDP_HOME/metadata/idp-metadata.xml

	# Update default URL to entity ID URL
	sed -i -e "s/idp3.victor.com/${ENTITY_ID}/g" $IDP_HOME/metadata/idp-metadata.xml

	# We have to update idp.properties with set and replace idp3.victor.com with $ENTITY_ID
	sed -i -e "s/idp3.victor.com/${ENTITY_ID}/g" $IDP_HOME/conf/idp.properties

	# We have to update idp.properties with set and replace idp.scope=victor.com with idp.scope=${SHIBBOLETH_SCOPE}
	sed -i -e "s/idp.scope=victor.com/idp.scope=${SHIBBOLETH_SCOPE}/g" $IDP_HOME/conf/idp.properties

	# We have to rebuild the war file so it has the proper properties
	$IDP_HOME/bin/build.sh -Didp.target.dir="$IDP_HOME"

	cp /default-shibboleth-files/conf-default/attribute-filter.xml $IDP_HOME/conf/attribute-filter.xml
	cp /default-shibboleth-files/conf-default/attribute-resolver.xml $IDP_HOME/conf/attribute-resolver.xml
	cp /default-shibboleth-files/conf-default/ldap.properties $IDP_HOME/conf/ldap.properties
	cp /default-shibboleth-files/conf-default/relying-party.xml $IDP_HOME/conf/relying-party.xml
	cp /default-shibboleth-files/conf-default/metadata-providers.xml $IDP_HOME/conf/metadata-providers.xml

	ldap_file_dirs="$IDP_HOME/conf/ldap.properties"
	LDAP_TLS=false

	ldap_url=""
	if [ $OPENLDAP_BOOTSTRAP_TLS == "true" ]; then
		ldap_url="ldaps\:\/\/${LDAP_CONTAINER_NAME}:6360"
	else
		ldap_url="ldap\:\/\/${LDAP_CONTAINER_NAME}:3890"
	fi 


	ldap_bind_dn="cn=admin,${OPENLDAP_BOOTSTRAP_SUFFIX}"
	ldap_dn_format="$LDAP_DN_FORMAT,${OPENLDAP_BOOTSTRAP_SUFFIX}"
	
	do_replace $(grep "idp.authn.LDAP.ldapURL=" "$ldap_file_dirs") "$ldap_url" "$ldap_file_dirs"
	do_replace $(grep "idp.authn.LDAP.baseDN=" "$ldap_file_dirs") "$OPENLDAP_BOOTSTRAP_SUFFIX" "$ldap_file_dirs" # new
	do_replace $(grep "idp.authn.LDAP.bindDN=" "$ldap_file_dirs") "$ldap_bind_dn" "$ldap_file_dirs"    # new
	do_replace $(grep "idp.authn.LDAP.dnFormat=" "$ldap_file_dirs") "$ldap_dn_format" "$ldap_file_dirs"   # new
	do_replace $(grep "idp.authn.LDAP.useStartTLS=" "$ldap_file_dirs") "$LDAP_TLS" "$ldap_file_dirs"
	do_replace $(grep "idp.authn.LDAP.bindDNCredential=" "$ldap_file_dirs") "$LDAP_ADMIN_PASSWORD" "$ldap_file_dirs"  # new
	do_replace $(grep "idp.authn.LDAP.disableHostnameVerification=" "$ldap_file_dirs") "$LDAP_DISABLE_HOST_NAME_VERIFICATION" "$ldap_file_dirs"  # new

	cp /default-shibboleth-files/views-default/login.vm $IDP_HOME/views/login.vm
	cp /default-shibboleth-files/views-default/error.vm $IDP_HOME/views/error.vm 

	cp -R /default-shibboleth-files/jetty-default/root $JETTY_BASE/webapps/root
	cp -R /default-shibboleth-files/jetty-default/webapps/idp.xml $JETTY_BASE/webapps/idp.xml
	touch /installed

fi 

if ! command -v -- "$1" >/dev/null 2>&1 ; then
	set -- java -jar "$JETTY_HOME/start.jar" "$@"
fi

: ${TMPDIR:=/tmp/jetty}
[ -d "$TMPDIR" ] || mkdir -p $TMPDIR 2>/dev/null

: ${JETTY_START:=$JETTY_BASE/jetty.start}

case "$JAVA_OPTIONS" in
	*-Djava.io.tmpdir=*) ;;
	*) JAVA_OPTIONS="-Djava.io.tmpdir=$TMPDIR $JAVA_OPTIONS" ;;
esac

if expr "$*" : 'java .*/start\.jar.*$' >/dev/null ; then
	# this is a command to run jetty

	# check if it is a terminating command
	for A in "$@" ; do
		case $A in
			--add-module* |\
			--add-to-start* |\
			--create-files |\
			--create-start-ini |\
			--create-startd |\
			--download |\
			--dry-run |\
			--exec-print |\
			--help |\
			--info |\
			--list-all-modules |\
			--list-classpath |\
			--list-config |\
			--list-modules* |\
			--show-module* |\
			--stop |\
			--update-ini |\
			--version |\
			--write-module-graph* |\
			-v )\
			# It is a terminating command, so exec directly
			JAVA="$1"
			shift
			# The $START_OPTIONS is the JVM options for the JVM which will do the --dry-run.
			# The $JAVA_OPTIONS contains the JVM options used in the output of the --dry-run command.
			eval "exec $JAVA $START_OPTIONS \"\$@\" $JAVA_OPTIONS $JETTY_PROPERTIES"
		esac
	done

	if [ $(whoami) != "jetty" ]; then
		cat >&2 <<- EOWARN
			********************************************************************
			WARNING: User is $(whoami)
			         The user should be (re)set to 'jetty' in the Dockerfile
			********************************************************************
		EOWARN
	fi

	if [ -f $JETTY_START ] ; then

		# Search for the Jetty Version comment in the jetty.start file.
		JETTY_START_VERSION="$(
			grep -m1 '^# JETTY_VERSION:' "$JETTY_START" 2>/dev/null \
				| sed 's/^# JETTY_VERSION: //'
		)"

		# If the jetty.start file was generated with a different Jetty version we need to regenerate jetty.start.
		if [ "$JETTY_START_VERSION" != "$JETTY_VERSION" ]; then
			echo "$(date +'%Y-%m-%d %H:%M:%S'):INFO: Jetty version mismatch ($JETTY_START_VERSION -> $JETTY_VERSION), regenerating jetty.start" >&2
			/generate-jetty-start.sh "$@"

		# If the start.d directory has been modified we need to regenerate jetty.start.
		elif [ $JETTY_BASE/start.d -nt $JETTY_START ] ; then
			cat >&2 <<- EOWARN
			********************************************************************
			WARNING: The $JETTY_BASE/start.d directory has been modified since
			         the $JETTY_START files was generated.
			         To avoid regeneration delays at start, either delete
			         the $JETTY_START file or re-run /generate-jetty-start.sh
			         from a Dockerfile.
			********************************************************************
			EOWARN
			/generate-jetty-start.sh "$@"
		fi
		echo $(date +'%Y-%m-%d %H:%M:%S.000'):INFO:docker-entrypoint:jetty start from $JETTY_START
	else
		/generate-jetty-start.sh "$@"
	fi

	## The generate-jetty-start script always starts the jetty.start file with exec, so this command will exec Jetty.
  ## We need to do this because the file may have quoted arguments which cannot be read into a variable.
  . $JETTY_START
fi

if [ "${1##*/}" = java -a -n "$JAVA_OPTIONS" ] ; then
	JAVA="$1"
	shift
	set -- "$JAVA" $JAVA_OPTIONS "$@"
fi

exec "$@"
