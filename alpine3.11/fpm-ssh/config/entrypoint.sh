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

    ## Shell configuration (Drupal)
    { \
        echo 'export PATH="$PATH:/var/www/html/vendor/bin"'; \
    } >> "${SSH_HOME}"/.bashrc
    chown "${SSH_USER}":"${SSH_GROUP}" "${SSH_HOME}"/.bashrc

fi

## Image mode (dev | prod)
if [ "${IMAGE_MODE}" = "dev" ]; then

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
    } > /usr/local/etc/php/conf.d/zzz-overrides.ini

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
    #} > /usr/local/etc/php/conf.d/zzz-overrides.ini

fi

## Sendmail
{ \
    echo "mailhub=${SMTP_IP}:${SMTP_PORT}"; \
    echo 'FromLineOverride=YES'; \
    #echo 'hostname=project-name.local'; \
    #echo 'root=postmaster@project-name.local'; \
    #echo 'rewriteDomain=project-name.local'; \
    #echo 'UseTLS=YES'; \
    #echo 'UseSTARTTLS=YES'; \
} > /etc/ssmtp/ssmtp.conf

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