#!/bin/bash                                                                     
############################################################                    
#                                                                               
# Author : Sébastien Allamand                                                   
#                                                                               
# Fichier de demarrage du docker apache-ssl-proxy
#                                                                               
# On precise une variable d'environnement PFS pour                              
# parametrer le container avec un environnement voulu.                          
#                                                                               
############################################################                    


export TZ=GMT
export LANG=en_US.UTF-8


if [ "$1" = 'httpd' ]; then

    # Env says we're using SSL                                                              
    if [ -n "${ENABLE_SSL+1}" ] && [ "${ENABLE_SSL,,}" = "true" ]; then
	echo "Enabling SSL..."
	cp /apache/httpd.conf /usr/local/apache2/conf/httpd.conf
    else
	# No SSL
	cp /apache/httpd_nossl.conf /usr/local/apache2/conf/httpd.conf
    fi
    
    # If an htpasswd file is provided, download and configure nginx                         
    if [ -n "${ENABLE_BASIC_AUTH+1}" ] && [ "${ENABLE_BASIC_AUTH,,}" = "true" ]; then
	echo "Enabling basic auth..."
	sed -i "s/#ab//g;" /usr/local/apache2/conf/httpd.conf
    fi

    #If we have a basic Auth require expression we add it
    if [ -n "${BASIC_AUTH_REQUIRE_EXPR+1}" ]; then
	echo "Enabling basic auth Require Expression (char @ if forbidden in var value!!)..."
	sed -i "s/#reqexpr//g;" /usr/local/apache2/conf/httpd.conf
	sed -i "s@{{require_expr}}@${BASIC_AUTH_REQUIRE_EXPR}@" /usr/local/apache2/conf/httpd.conf
    fi
    
    
    if [ -n "${TARGET_SERVICE+1}" ]; then
	# Tell apache the address and port of the service to proxy to                            
	sed -i "s#{{TARGET_SERVICE}}#${TARGET_SERVICE}#g;" /usr/local/apache2/conf/httpd.conf
    else
	echo "You must privide Environment var TARGET_SERVICE"
	exit -1
    fi

    #logs to stdout & stderr
    rm -f /error_log /httpd.pid /access_log
    ln -s /dev/stderr /error_log
    ln -s /dev/stdout /access_log
    
    
    
    
    echo "starting apache"
    rm -f /usr/local/apache2/logs/httpd.pid
    exec httpd -D FOREGROUND
    
fi

#default execute given command (ex docker run image bash)
echo "exec you're command"
exec $@

