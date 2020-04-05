ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.11

FROM php:${PHP_VERSION:+${PHP_VERSION}-}fpm-alpine${ALPINE_VERSION}

ENV PROJECT_MODE dev
ENV DOCUMENT_ROOT /var/www/html/public
ENV PHP_HOME /var/www
ENV PHP_USER user
ENV GIT_EMAIL my@email.com
## Equivalent ways of writing a variable: ENV GIT_NAME=My\ Name | ENV GIT_NAME="My Name"
## Attention: ENV GIT_NAME="" does not contain empty string, but contains ""
ENV GIT_NAME My Name
ENV SMTP_HOSTNAME 192.168.99.100
ENV SMTP_PORT 1025
ENV SMTP_FROM team@example.com
## A way, how to create an unset variable
ENV SMTP_USER ${UNSET}
ENV SMTP_PASSWORD password
## Proxy server example: "http://user:password@proxy.example.com:8080"
ENV PROXY_SERVER=${UNSET}

## https://github.com/mlocati/docker-php-extension-installer/
## php -r 'print_r(gd_info());'
RUN echo "PHP extensions" \
&&  wget https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions \
&&  mv install-php-extensions /usr/local/bin/ \
&&  chmod +x /usr/local/bin/install-php-extensions \
&&  sync \
&&  install-php-extensions \
        ## PHP-FPM + PHP-CLI
        pdo_mysql mysqli \
        pdo_pgsql pgsql \
        mongodb \
        gd \
        imagick \
        ## PHP-FPM
        ldap \
        exif \
        bcmath \
        zip \
        intl \
        apcu \
        opcache \
        ## PHP-CLI
        #xdebug \
&&  rm /usr/local/bin/install-php-extensions

## ToDo: ICU 65.1 (now 64.2)

RUN echo "PHP extension: uploadprogress" \
&&  apk add --no-cache --virtual .build-deps \
        git \
&&  git clone https://github.com/php/pecl-php-uploadprogress/ /usr/src/php/ext/uploadprogress/ \
&&  docker-php-ext-install uploadprogress \
&&  rm -fr /usr/src/php/ext/uploadprogress \
&&  apk del --purge .build-deps

## php.ini configuration viz entrypoint.sh

RUN echo "Sendmail" \
&&  apk add --no-cache msmtp \
&&  echo 'sendmail_path = /usr/bin/msmtp -t --read-envelope-from' > /usr/local/etc/php/conf.d/mail.ini
#&&  echo 'sendmail_path = /usr/bin/msmtp -t' > /usr/local/etc/php/conf.d/mail.ini
## Sendmail configuraton viz entrypoint.sh

## MongoDB - missing in oficial repository (in this repository is old version)
#RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories \
#&&  apk add --no-cache \
#        mongodb \
#        mongodb-tools

RUN echo "System tools" \
&&  apk add --no-cache \
        ## Certificates
        ca-certificates \
        openssl \
        ## Wordpress
        ghostscript

## Create document root
#RUN mkdir -p "${DOCUMENT_ROOT}"

RUN echo "Default data" \
&&  apk add --no-cache --virtual .build-deps \
        git \
&&  git clone https://gitlab.com/vavyskov/webserver-info.git /tmp/webserver-info \
&&  cp -R /tmp/webserver-info/src/. ${DOCUMENT_ROOT} \
#&&  rm ${DOCUMENT_ROOT}/index.html \
&&  rm -fr /tmp/webserver-info \
&&  apk del --purge .build-deps \
&&  chown -R 82:82 ${DOCUMENT_ROOT}

## Set permission (82 is the standard uid/gid for "www-data" in Alpine)
#RUN chown -R 82:82 ${PHP_HOME}

## Initialize container
COPY config/entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
#ENTRYPOINT	[ "entrypoint.sh", "docker-php-entrypoint" ]

WORKDIR /var/www

EXPOSE 9000

#COPY wait-for-it.sh /usr/bin/wait-for-it
#RUN chmod +x /usr/bin/wait-for-it

#CMD composer install; wait-for-it database:3306 -- bin/console doctrine:migrations:migrate; php-fpm
CMD ["php-fpm"]
