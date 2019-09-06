## https://hub.docker.com/r/aexchecker/docker-php/dockerfile/
## https://hub.docker.com/r/wodby/drupal-php/dockerfile/

ARG PHP_VERSION=7.2

FROM php:${PHP_VERSION:+${PHP_VERSION}-}fpm-alpine3.10

ENV USER_HOME=/var/www
ENV DOCUMENT_ROOT=/var/www/html/public

## PHP extension: MySQL, MariaDB, Percona Server, or equivalent (Wordpress: mysqli, Drupal: pdo_mysqli)
RUN docker-php-ext-install mysqli pdo_mysql

## PHP extension: opcache
RUN docker-php-ext-install opcache

## PHP extension: exif
RUN docker-php-ext-install exif

## PHP extension: bcmath
RUN docker-php-ext-install bcmath

## PHP extension: gd (next librarires: libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev)
RUN apk add --no-cache --update --virtual .build-deps \
        libpng-dev \
&&  apk add --no-cache \
        libpng \
&&  docker-php-ext-install gd \
&&  apk del .build-deps

## PHP extension: zip
RUN apk add --no-cache --virtual .build-deps \
        libzip-dev \
#&&  docker-php-ext-configure zip --with-libzip \
#&&  docker-php-ext-configure zip \
&&  docker-php-ext-install zip \
&&  apk del --purge .build-deps

## PHP extension: intl
RUN apk add --no-cache --update --virtual .build-deps \
        icu-dev \
&&  docker-php-ext-install intl \
&&  apk del .build-deps

## PHP extension: xdebug
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
&&  pecl install xdebug \
&&  docker-php-ext-enable xdebug \
&&  pecl clear-cache \
&&  apk del .build-deps

## PHP extension: apcu
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
&&  pecl install apcu \
&&  docker-php-ext-enable apcu \
&&  pecl clear-cache \
&&  apk del .build-deps

## PHP extension: imagick
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
        imagemagick-dev \
&&  apk add --no-cache \
        imagemagick \
&&  pecl install imagick \
&&  docker-php-ext-enable imagick \
&&  pecl clear-cache \
&&  apk del .build-deps

## PHP extension: mongodb
RUN apk add --no-cache --update --virtual .build-deps \
        ${PHPIZE_DEPS} \
        #openssl-dev \
        #pcre-dev \
&&  pecl install mongodb \
&&  docker-php-ext-enable mongodb \
&&  pecl clear-cache \
&&  apk del .build-deps



## PHP extension: PECL uploadprogress
RUN apk add --no-cache git \
&&  git clone https://github.com/php/pecl-php-uploadprogress/ /usr/src/php/ext/uploadprogress/ \
&&  docker-php-ext-install uploadprogress \
&&  rm -fr /usr/src/php/ext/uploadprogress \
&&  apk del git

## Composer (get path command: which composer)
#COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

## Create document root
RUN mkdir -p "${DOCUMENT_ROOT}"

## Copy default data
COPY config/public ${DOCUMENT_ROOT}

## Set permission (82 is the standard uid/gid for "www-data" in Alpine)
RUN chown -R 82:82 ${USER_HOME}

## Sendmail
RUN apk add --no-cache ssmtp \
&&  echo 'sendmail_path = /usr/sbin/ssmtp -t' > /usr/local/etc/php/conf.d/mail.ini
COPY config/ssmtp.conf /etc/ssmtp







#RUN apk add --no-cache --update --virtual .build-deps \
#        postgresql-dev \
#&&  docker-php-ext-install pdo_pgsql \
#&&  apk del .build-deps




# ldap

