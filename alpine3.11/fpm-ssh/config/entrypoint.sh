#!/bin/sh
## Exit script if any command fails (non-zero status)
set -e

## Get standard web user and group (standard uid/gid for "www-data" for Alpine: 82, for Debian: 33)
WEB_USER=$(getent passwd 82 | cut -d: -f1)
WEB_GROUP=$(getent group 82 | cut -d: -f1)

## Simplification
SSH_GROUP=${SSH_USER}

## Change home
## From: www-data:x:82:82:Linux User,,,:/home/www-data:/sbin/nologin
## To:   www-data:x:82:82:Linux User,,,:/var/www:/sbin/nologin
## Syntax: sed -i "/SEARCH/s/FIND/REPLACE/" /etc/passwd
sed -i "/82/s/home\/${WEB_USER}/var\/www/" /etc/passwd
chown "${WEB_USER}":"${WEB_GROUP}" "${SSH_HOME}"

## Set shell for standard web user (enable login)
## From: www-data:x:82:82:Linux User,,,:/var/www:/sbin/nologin
## To:   www-data:x:82:82:Linux User,,,:/var/www:/bin/sh
## Syntax: sed -i "/SEARCH/s/FIND/REPLACE/" /etc/passwd
sed -i "/82/s/sbin\/nologin/bin\/sh/" /etc/passwd

## Test if strings are not empty
if [ -n "${SSH_USER}" ] && [ -n "${SSH_PASSWORD}" ]; then

    ## Test if users are not the same
    if [ "${WEB_USER}" != "${SSH_USER}" ]; then

        ## Change home
        #mv /home/"${WEB_USER}" ${SSH_HOME}"

        ## Change group
        ## From: www-data:x:82:www-data
        ## To:   new-group:x:82:new-group
        ## Syntax: sed -i "s/FIND/REPLACE/" /etc/group
        sed -i "s/${WEB_GROUP}:x:82:${WEB_GROUP}/${SSH_GROUP}:x:82:${SSH_GROUP}/" /etc/group

        ## Change user
        ## From: www-data:x:82:82:Linux User,,,:/var/www:/bin/sh
        ## To:   new-user:x:82:82:Linux User,,,:/var/www/bin/sh
        ## Syntax: sed -i "s/FIND/REPLACE/" /etc/passwd
        sed -i "s/${WEB_USER}:x:82/${SSH_USER}:x:82/" /etc/passwd

    fi

    ## Set user password
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd

    ## Create symbolic link
    #ln -s /var/www/html "${SSH_HOME}"/html
    #chown -h "${SSH_USER}":"${SSH_GROUP}" "${SSH_HOME}"/html

    ## Run php-fpm with proper user
    sed -i "s/user = ${WEB_USER}/user = ${SSH_USER}/g" /usr/local/etc/php-fpm.d/www.conf
    sed -i "s/group = ${WEB_GROUP}/group = ${SSH_GROUP}/g" /usr/local/etc/php-fpm.d/www.conf

    ## Shell configuration - Drupal
    { \
        echo 'export PATH="$PATH:/var/www/html/vendor/bin"'; \
    } >> "${SSH_HOME}"/.bashrc
    chown "${SSH_USER}":"${SSH_GROUP}" "${SSH_HOME}"/.bashrc

#    ## Shell configuration - Proxy (env | grep proxy)
#    if [ -n "${PROXY_SERVER}" ]; then
#        ## Shell configuration (Proxy)
#        { \
#            echo "export http_proxy='${PROXY_SERVER}'"; \
#            echo "export https_proxy='${PROXY_SERVER}'"; \
#            echo "export ftp_proxy='${PROXY_SERVER}'"; \
#        } >> "${SSH_HOME}"/.bashrc
#        chown "${SSH_USER}":"${SSH_GROUP}" "${SSH_HOME}"/.bashrc
#    fi

fi

## TimeZone (default is Europe/Prague)
if [ "${TIME_ZONE}" = "UTC" ]; then
    rm /etc/localtime
fi

## Image mode (dev | prod)
if [ "${PROJECT_MODE}" = "dev" ]; then

    ## Enable PHP extension
    sed -i "s/#zend_extension/zend_extension/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

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
    } > /usr/local/etc/php/conf.d/zz-overrides.ini

else

    ## Disable PHP extension
    sed -i "s/zend_extension/#zend_extension/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

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
    #{ \
    #  echo 'memory_limit = 128MB'; \
    #} > /usr/local/etc/php/conf.d/zz-overrides.ini

fi

## Sendmail
if [ -n "${SMTP_MAILHUB}" ] && [ -n "${SMTP_MAILHUB_PORT}" ] && [ -z "${SMTP_USER}" ]; then
    { \
        echo "mailhub=${SMTP_MAILHUB}:${SMTP_MAILHUB_PORT}"; \
        echo 'FromLineOverride=YES'; \
    } > /etc/ssmtp/ssmtp.conf
else
    { \
        echo '# root=postmaster@project-name.local'; \
        echo "mailhub=${SMTP_MAILHUB}:${SMTP_MAILHUB_PORT}"; \
        echo "rewriteDomain=${SMTP_DOMAIN}"; \
        echo "hostname=$(hostname -f)"; \
        echo '# TLS_CA_FILE=/etc/ssl/certs/ca-certificates.crt'; \
        echo '# UseTLS=YES'; \
        echo '# UseSTARTTLS=YES'; \
        echo "AuthUser=${SMTP_USER}"; \
        echo "AuthPass=${SMTP_PASSWORD}"; \
        echo "AuthMethod=${SMTP_METHOD}"; \
        echo 'FromLineOverride=YES'; \
    } > /etc/ssmtp/ssmtp.conf

#    cat << EOF > /etc/ssmtp/ssmtp.conf
#root=user@host.name
#hostname=host.name
#mailhub=smtp.host.name:465
#FromLineOverride=YES
#AuthUser=username@gmail.com
#AuthPass=password
#AuthMethod=LOGIN
#UseTLS=YES
#EOF

fi

## Proxy (env | grep proxy)
if [ -n "${PROXY_SERVER}" ]; then
    for i in wget composer npm yarn
    do
        { \
            echo '#!/bin/sh'; \
            echo "export http_proxy='${PROXY_SERVER}'"; \
            echo "export https_proxy='${PROXY_SERVER}'"; \
            echo "export ftp_proxy='${PROXY_SERVER}'"; \
            echo "/usr/bin/$i \$@"; \
            echo 'unset http_proxy'; \
            echo 'unset https_proxy'; \
            echo 'unset ftp_proxy'; \
        } > /usr/local/bin/$i
        chmod +x /usr/local/bin/$i
    done
fi

## Git
{ \
    echo '[user]'; \
    echo "    name = ${GIT_NAME}"; \
    echo "    email = ${GIT_EMAIL}"; \
    echo '[core]'; \
    echo '    autocrlf = false'; \
} > "${SSH_HOME}"/.gitconfig
chown "${SSH_USER}":"${SSH_GROUP}" "${SSH_HOME}"/.gitconfig

## SSH key
if [ -d "${SSH_HOME}"/.shared/.ssh ]; then
    cp -R "${SSH_HOME}"/.shared/.ssh "${SSH_HOME}"/.ssh
    chown -R "${SSH_USER}":"${SSH_GROUP}" "${SSH_HOME}"/.ssh
fi

## Make the entrypoint a pass through that then runs the docker command (redirect all input arguments)
exec "$@"