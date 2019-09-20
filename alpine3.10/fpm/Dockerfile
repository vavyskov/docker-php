## https://hub.docker.com/r/llaumgui/php/dockerfile
## https://hub.docker.com/r/aexchecker/docker-php/dockerfile/
## https://hub.docker.com/r/wodby/drupal-php/dockerfile/

ARG PHP_VERSION=7.2

FROM php:${PHP_VERSION:+${PHP_VERSION}-}fpm-alpine3.10

ENV USER_HOME=/var/www
ENV DOCUMENT_ROOT=/var/www/html/public

## PHP extension: MySQL, MariaDB, Percona Server, or equivalent (Wordpress: mysqli, Drupal: pdo_mysqli)
RUN docker-php-ext-install \
        mysqli \
        pdo_mysql

## PHP extension: opcache
RUN docker-php-ext-install opcache

## PHP extension: exif
RUN docker-php-ext-install exif

## PHP extension: bcmath
RUN docker-php-ext-install bcmath

## PHP extension: gd (other librarires: libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev)
RUN apk add --no-cache --update --virtual .build-deps \
        libpng-dev \
&&  apk add --no-cache \
        libpng \
&&  docker-php-ext-install gd \
&&  apk del --purge .build-deps

## PHP extension: zip
RUN apk add --no-cache --update --virtual .build-deps \
        libzip-dev \
#&&  apk add --no-cache \
#        libzip \
#&&  docker-php-ext-configure zip --with-libzip \
&&  docker-php-ext-install zip \
&&  apk del --purge .build-deps

## PHP extension: intl
RUN apk add --no-cache --update --virtual .build-deps \
        icu-dev \
&&  apk add --no-cache \
        icu-libs \
        libintl \
#&&  docker-php-ext-configure intl --with-icu-dir=/usr/local
&&  docker-php-ext-install intl \
&&  apk del --purge .build-deps

## PHP extension: ldap
RUN apk add --no-cache --update --virtual .build-deps \
        openldap-dev \
&&  apk add --no-cache \
        libldap \
&&  docker-php-ext-install \
        ldap \
&&  apk del --purge .build-deps

## PHP extension: pgsql
RUN apk add --no-cache --update --virtual .build-deps \
        postgresql-dev \
        #postgresql-client \
&&  apk add --no-cache \
        libpq \
&&  docker-php-ext-install \
        pdo_pgsql \
        pgsql \
&&  apk del --purge .build-deps

## PHP extension: imagick
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
        imagemagick-dev \
&&  apk add --no-cache \
        imagemagick \
&&  pecl install imagick \
&&  docker-php-ext-enable imagick \
&&  pecl clear-cache \
&&  apk del --purge .build-deps

## PHP extension: apcu
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
&&  pecl install apcu \
&&  docker-php-ext-enable apcu \
&&  pecl clear-cache \
&&  apk del --purge .build-deps

## PHP extension: mongodb
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
        #openssl-dev \
        #pcre-dev \
&&  pecl install mongodb \
&&  docker-php-ext-enable mongodb \
&&  pecl clear-cache \
&&  apk del --purge .build-deps

## PHP extension: xdebug
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
&&  pecl install xdebug \
&&  docker-php-ext-enable xdebug \
&&  pecl clear-cache \
&&  apk del --purge .build-deps \
&&  echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini

## PHP extension: uploadprogress
RUN apk add --no-cache --update --virtual .build-deps \
        git \
&&  git clone https://github.com/php/pecl-php-uploadprogress/ /usr/src/php/ext/uploadprogress/ \
&&  docker-php-ext-install uploadprogress \
&&  rm -fr /usr/src/php/ext/uploadprogress \
&&  apk del --purge .build-deps



## Set recommended PHP.ini settings
RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
#RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
#RUN { \
#        echo 'opcache.max_accelerated_files=10000'; \
#    } > /usr/local/etc/php/conf.d/opcache-recommended.ini
#
### Configure error logging
#RUN { \
#        echo 'error_log = /dev/stderr'; \
#    } > /usr/local/etc/php/conf.d/error-logging.ini



## Composer (get path command: which composer)
#COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

## Sendmail
RUN apk add --no-cache ssmtp \
&&  echo 'sendmail_path = /usr/sbin/ssmtp -t' > /usr/local/etc/php/conf.d/mail.ini \
&&  { \
        echo 'mailhub=192.168.99.100:1025'; \
        echo 'FromLineOverride=YES'; \
    } > /etc/ssmtp/ssmtp.conf
#COPY config/ssmtp.conf /etc/ssmtp

## Node.js
RUN apk add --no-cache \
        npm \
        nodejs \
## Yarn
&&  npm install -g yarn

## System tools
RUN apk add --no-cache \
        ghostscript \
        git \
        patch \
        wget \
        curl \
        tar \
        zip \
        unzip \
        vim \
        mc

## Create document root
RUN mkdir -p "${DOCUMENT_ROOT}"

## Copy default data
RUN apk add --no-cache --update --virtual .build-deps \
        git \
&&  git clone https://gitlab.com/vavyskov/webserver-info.git /tmp/webserver-info \
&&  cp -R /tmp/webserver-info/src/. ${DOCUMENT_ROOT} \
&&  rm ${DOCUMENT_ROOT}/index.html \
&&  rm -fr /tmp/webserver-info \
&&  apk del --purge .build-deps

## Set permission (82 is the standard uid/gid for "www-data" in Alpine)
RUN chown -R 82:82 ${USER_HOME}
