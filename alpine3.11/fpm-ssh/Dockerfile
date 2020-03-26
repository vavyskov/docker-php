ARG PHP_VERSION=7.4

FROM php:${PHP_VERSION:+${PHP_VERSION}-}fpm-alpine3.11

ENV IMAGE_MODE=dev
#ENV DOCUMENT_ROOT=/var/www/html/public
ENV SSH_HOME=/var/www
ENV SSH_USER=ssh
ENV SSH_PASSWORD=ssh
ENV GIT_EMAIL=my@email.com
ENV GIT_NAME="My Name"
ENV SMTP_IP=192.168.99.100
ENV SMTP_PORT=1025

## PHP extension: MySQL, MariaDB, Percona Server, or equivalent (Wordpress: mysqli, Drupal: pdo_mysql)
RUN echo "PHP extension: mysqli pdo_mysql" \
&&  docker-php-ext-install \
        mysqli \
        pdo_mysql

RUN echo "PHP extension: opcache" \
&&  docker-php-ext-install \
        opcache
#COPY config/opcache.ini /usr/local/etc/php/conf.d/

RUN echo "PHP extension: exif" \
&&  docker-php-ext-install \
        exif

RUN echo "PHP extension: bcmath" \
&&  docker-php-ext-install \
        bcmath

## PHP extension: gd (other librarires: libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev)
RUN echo "PHP extension: gd" \
&&  apk add --no-cache --virtual .build-deps \
        libpng-dev \
&&  apk add --no-cache \
        libpng \
&&  docker-php-ext-install gd \
&&  apk del --purge .build-deps

RUN echo "PHP extension: zip" \
&&  apk add --no-cache --virtual .build-deps \
        libzip-dev \
&&  apk add --no-cache \
        libzip \
&&  docker-php-ext-install zip \
&&  apk del --purge .build-deps

## ToDo: ICU 65.1 (now 64.2)
RUN echo "PHP extension: intl" \
&&  apk add --no-cache --virtual .build-deps \
        icu-dev \
&&  apk add --no-cache \
        icu-libs \
        libintl \
#&&  docker-php-ext-configure intl --with-icu-dir=/usr/local
&&  docker-php-ext-install intl \
&&  apk del --purge .build-deps

RUN echo "PHP extension: ldap" \
&&  apk add --no-cache --virtual .build-deps \
        openldap-dev \
&&  apk add --no-cache \
        libldap \
&&  docker-php-ext-install \
        ldap \
&&  apk del --purge .build-deps

RUN echo "PHP extension: pgsql pdo_pgsql" \
&&  apk add --no-cache --virtual .build-deps \
        postgresql-dev \
        #postgresql-client \
&&  apk add --no-cache \
        libpq \
&&  docker-php-ext-install \
        pgsql \
        pdo_pgsql \
&&  apk del --purge .build-deps

RUN echo "PHP extension: imagick" \
&&  apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS} \
        imagemagick-dev \
&&  apk add --no-cache \
        imagemagick \
&&  pecl install imagick \
&&  docker-php-ext-enable imagick \
&&  pecl clear-cache \
&&  apk del --purge .build-deps

RUN echo "PHP extension: apcu" \
&&  apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS} \
&&  pecl install apcu \
&&  docker-php-ext-enable apcu \
&&  pecl clear-cache \
&&  apk del --purge .build-deps

RUN echo "PHP extension: mongodb" \
&&  apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS} \
        #openssl-dev \
        #pcre-dev \
&&  pecl install mongodb \
&&  docker-php-ext-enable mongodb \
&&  pecl clear-cache \
&&  apk del --purge .build-deps

RUN echo "PHP extension:  xdebug" \
&&  apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS} \
&&  pecl install xdebug \
&&  docker-php-ext-enable xdebug \
&&  pecl clear-cache \
&&  apk del --purge .build-deps \
&&  echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN echo "PHP extension: uploadprogress" \
&&  apk add --no-cache --virtual .build-deps \
        git \
&&  git clone https://github.com/php/pecl-php-uploadprogress/ /usr/src/php/ext/uploadprogress/ \
&&  docker-php-ext-install uploadprogress \
&&  rm -fr /usr/src/php/ext/uploadprogress \
&&  apk del --purge .build-deps

## php.ini configuration viz entrypoint.sh

## Composer (get path command: which composer)
#COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN echo "Sendmail" \
&&  apk add --no-cache ssmtp \
&&  echo 'sendmail_path = /usr/sbin/ssmtp -t' > /usr/local/etc/php/conf.d/mail.ini
## Sendmail configuraton viz entrypoint.sh

RUN echo "nodejs yarn" \
&&  apk add --no-cache \
        npm \
        nodejs \
&&  npm install -g yarn

RUN echo "SSH" \
&&  apk add --no-cache \
        openssh \
        #bash \
&&  ssh-keygen -A \
#&&  sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
&&  sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config

## MongoDB - missing in oficial repository (in this repository is old version)
#RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories \
#&&  apk add --no-cache \
#        mongodb \
#        mongodb-tools

RUN echo "System tools" \
&&  apk add --no-cache \
        ghostscript \
        git \
        #patch \
        #wget \
        #curl \
        #tar \
        zip \
        #unzip \
        vim \
        mc

RUN echo "Symfony CLI" \
&&  apk add --no-cache --virtual .build-deps \
        bash \
&&  wget https://get.symfony.com/cli/installer -O - | bash \
&&  mv /root/.symfony/bin/symfony /usr/local/bin/symfony \
&&  apk del --purge .build-deps

## Create document root
#RUN mkdir -p "${DOCUMENT_ROOT}"

#RUN echo "Default data" \
#&&  apk add --no-cache --virtual .build-deps \
#        git \
#&&  git clone https://gitlab.com/vavyskov/webserver-info.git /tmp/webserver-info \
#&&  cp -R /tmp/webserver-info/src/. ${DOCUMENT_ROOT} \
##&&  rm ${DOCUMENT_ROOT}/index.html \
#&&  rm -fr /tmp/webserver-info \
#&&  apk del --purge .build-deps \
#&&  chown -R 82:82 ${DOCUMENT_ROOT}

## Set permission (82 is the standard uid/gid for "www-data" in Alpine)
#RUN chown -R 82:82 ${SSH_HOME}

RUN echo "Multi-services" \
&&  apk add --no-cache \
        supervisor
COPY config/supervisord.conf /etc/supervisord/conf.d/

## Initialize container
COPY config/entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
#ENTRYPOINT	[ "entrypoint.sh", "docker-php-entrypoint" ]

WORKDIR /var/www

EXPOSE 9000 22

#CMD ["php-fpm"]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord/conf.d/supervisord.conf"]