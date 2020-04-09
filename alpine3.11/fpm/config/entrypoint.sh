#!/bin/sh
## Exit script if any command fails (non-zero status)
set -e

## Get standard web user and group (standard uid/gid for "www-data" for Alpine: 82, for Debian: 33)
WEB_USER=$(getent passwd 82 | cut -d: -f1)
WEB_GROUP=$(getent group 82 | cut -d: -f1)

## Simplification
PHP_USER_GROUP=${PHP_USER}

## Change home
## From: www-data:x:82:82:Linux User,,,:/home/www-data:/sbin/nologin
## To:   www-data:x:82:82:Linux User,,,:/var/www:/sbin/nologin
## Syntax: sed -i "/SEARCH/s/FIND/REPLACE/" /etc/passwd
sed -i "/82/s/home\/${WEB_USER}/var\/www/" /etc/passwd
chown "${WEB_USER}":"${WEB_GROUP}" "${PHP_HOME}"

## Test if strings are not empty
if [ -n "${PHP_USER}" ]; then

    ## Test if users are not the same
    if [ "${WEB_USER}" != "${PHP_USER}" ]; then

        ## Change home
        #mv /home/"${WEB_USER}" ${PHP_HOME}"

        ## Change group
        ## From: www-data:x:82:www-data
        ## To:   new-group:x:82:new-group
        ## Syntax: sed -i "s/FIND/REPLACE/" /etc/group
        sed -i "s/${WEB_GROUP}:x:82:${WEB_GROUP}/${PHP_USER_GROUP}:x:82:${PHP_USER_GROUP}/" /etc/group

        ## Change user
        ## From: www-data:x:82:82:Linux User,,,:/var/www:/bin/sh
        ## To:   new-user:x:82:82:Linux User,,,:/var/www/bin/sh
        ## Syntax: sed -i "s/FIND/REPLACE/" /etc/passwd
        sed -i "s/${WEB_USER}:x:82/${PHP_USER}:x:82/" /etc/passwd

    fi

    ## Create symbolic link
    #ln -s /var/www/html "${PHP_HOME}"/html
    #chown -h "${PHP_USER}":"${PHP_USER_GROUP}" "${PHP_HOME}"/html

    ## Run php-fpm with proper user
    sed -i "s/user = ${WEB_USER}/user = ${PHP_USER}/g" /usr/local/etc/php-fpm.d/www.conf
    sed -i "s/group = ${WEB_GROUP}/group = ${PHP_USER_GROUP}/g" /usr/local/etc/php-fpm.d/www.conf

#    ## Shell configuration - Proxy (env | grep proxy)
#    if [ -n "${PROXY_SERVER}" ]; then
#        ## Shell configuration (Proxy)
#        { \
#            echo "export http_proxy='${PROXY_SERVER}'"; \
#            echo "export https_proxy='${PROXY_SERVER}'"; \
#            echo "export ftp_proxy='${PROXY_SERVER}'"; \
#        } >> "${PHP_HOME}"/.bashrc
#        chown "${PHP_USER}":"${PHP_USER_GROUP}" "${PHP_HOME}"/.bashrc
#    fi

fi

## Image mode (dev | prod)
if [ "${PROJECT_MODE}" = "dev" ]; then

#    ## Enable PHP extension
#    sed -i "s/#zend_extension/zend_extension/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

    ## Recommended php.ini settings (/usr/local/etc/php/php.ini)
    cp "$PHP_INI_DIR"/php.ini-development "$PHP_INI_DIR"/php.ini

    ## Configure Opcache
    #{ \
    #    echo 'opcache.max_accelerated_files=10000'; \
    #} > /usr/local/etc/php/conf.d/opcache-recommended.ini

    ## Override recommended php.ini
    { \
      echo '[Performance]'; \
      echo 'memory_limit = -1'; \
      echo 'max_execution_time = 300'; \
      echo ''; \
      echo '[Time zone]'; \
      echo 'date.timezone = "Europe/Prague"'; \
      echo ''; \
      echo '[Error reporting]'; \
      echo 'error_log = /dev/stderr'; \
      #echo 'error_log = php_error.log'; \
      echo 'html_errors = On'; \
      echo ''; \
      echo '[Upload files]'; \
      echo 'upload_max_filesize = 128M'; \
      echo 'post_max_size = 256M'; \
      echo ''; \
      #echo '[OPcode extension]'; \
      #echo 'opcache.memory_consumption = 128'; \
      #echo 'opcache.interned_strings_buffer = 8'; \
      #echo 'opcache.max_accelerated_files = 10000'; \
      #echo 'opcache.revalidate_freq = 2'; \
      #echo 'opcache.huge_code_pages = 0'; \
      #echo ''; \
      #echo '[Drupal Commerce Kickstart]'; \
      #echo 'mbstring.http_input = pass'; \
      #echo 'mbstring.http_output = pass'; \
      #echo ''; \
      #echo '[MongoDB]'; \
      #echo 'extension=mongo.so'; \
      #echo 'extension=mongodb.so'; \
    } > /usr/local/etc/php/conf.d/zzz-overrides.ini

else

#    ## Disable PHP extension
#    sed -i "s/zend_extension/#zend_extension/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

    ## Recommended php.ini settings (/usr/local/etc/php/php.ini)
    cp "$PHP_INI_DIR"/php.ini-production "$PHP_INI_DIR"/php.ini

    ## Configure Opcache
    #{ \
    #    echo 'opcache.max_accelerated_files=10000'; \
    #} > /usr/local/etc/php/conf.d/opcache.ini

    ## Configure error reporting
    #{ \
    #    echo 'error_log = /dev/stderr'; \
    #} > /usr/local/etc/php/conf.d/error-reporting.ini

    ## Override recommended php.ini
    { \
      echo '[Time zone]'; \
      echo 'date.timezone = "Europe/Prague"'; \
    } > /usr/local/etc/php/conf.d/zzz-overrides.ini

fi

## Sendmail
if [ -n "${SMTP_HOSTNAME}" ] && [ -n "${SMTP_PORT}" ] && [ -z "${SMTP_USER}" ]; then
    { \
        echo 'account default'; \
        echo "host ${SMTP_HOSTNAME}"; \
        echo "port ${SMTP_PORT}"; \
        echo "from ${SMTP_FROM}";
        echo '#syslog on'; \
        echo '#logfile /var/log/msmtp.log'; \
    } > /etc/msmtprc
else
    { \
        echo 'account default'; \
        echo "host ${SMTP_HOSTNAME}"; \
        echo "port ${SMTP_PORT}"; \
        echo "from ${SMTP_FROM}"; \
        echo '#syslog on'; \
        echo '#logfile /var/log/msmtp.log'; \
        echo 'auth login'; \
        echo "user ${SMTP_USER}"; \
        echo "password ${SMTP_PASSWORD}"; \
        echo '#tls on'; \
        echo 'tls_starttls on'; \
        echo 'tls_trust_file /etc/ssl/certs/ca-certificates.crt'; \
        echo 'tls_certcheck on'; \
    } > /etc/msmtprc

#    cat << EOF > /etc/msmtprc
#account default
#host ${SMTP_HOSTNAME}
#port ${SMTP_PORT}
#from ${SMTP_FROM}
#syslog on
#logfile /var/log/msmtp.log
#auth login
#user ${SMTP_USER}
#password ${SMTP_PASSWORD}
##tls on
#tls_starttls on
#tls_trust_file /etc/ssl/certs/ca-certificates.crt
#tls_certcheck on
#EOF

fi

## Make the entrypoint a pass through that then runs the docker command (redirect all input arguments)
exec "$@"