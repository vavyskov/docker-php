ARG PHP_VERSION=7.2

FROM php:${PHP_VERSION:+${PHP_VERSION}-}apache-stretch

ENV USER_HOME=/var/www
ENV DOCUMENT_ROOT=/var/www/html/public

## PHP extension: MySQL, MariaDB, Percona Server, or equivalent (Wordpress: mysqli, Drupal: pdo_mysql)
RUN echo "PHP extension: mysqli pdo_mysql" \
&&  docker-php-ext-install \
        mysqli \
        pdo_mysql

RUN echo "PHP extension: opcache" \
&&  docker-php-ext-install \
        opcache

RUN echo "PHP extension: exif" \
&&  docker-php-ext-install \
        exif

RUN echo "PHP extension: bcmath" \
&&  docker-php-ext-install \
        bcmath

RUN echo "PHP extension: gd" \
&&  buildDeps=" \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libpng-dev \
" \
&&  apt-get update \
&&  apt-get install -y $buildDeps --no-install-recommends \
&&  rm -rf /var/lib/apt/lists/* \
&&  docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
&&  docker-php-ext-install -j $(nproc) \
        gd \
&&  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

RUN echo "PHP extension: zip" \
&&  buildDeps=" \
        libzip-dev \
" \
&&  apt-get update \
&&  apt-get install -y $buildDeps --no-install-recommends \
&&  rm -rf /var/lib/apt/lists/* \
&&  docker-php-ext-install -j $(nproc) \
        zip \
&&  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

RUN echo "PHP extension: intl" \
&&  buildDeps=" \
        zlib1g-dev \
        libicu-dev \
        g++ \
" \
&&  apt-get update \
&&  apt-get install -y $buildDeps --no-install-recommends \
&&  rm -rf /var/lib/apt/lists/* \
&&  docker-php-ext-install -j $(nproc) \
        intl \
&&  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

## ICU - intl requirements for Symfony
## Debian is out of date, and Symfony expects the latest - so build from source, unless a better alternative exists(?)
#RUN curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/58.2/icu4c-58_2-src.tgz \
#&&  tar -zxf /tmp/icu.tar.gz -C /tmp \
#&&  cd /tmp/icu/source \
#&&  ./configure --prefix=/usr/local \
#&&  make \
#&&  make install \
#&&  docker-php-ext-configure intl --with-icu-dir=/usr/local \
#&&  docker-php-ext-install intl

RUN echo "PHP extension: ldap" \
&&  buildDeps=" \
        libldap2-dev \
" \
&&  apt-get update \
&&  apt-get install -y $buildDeps --no-install-recommends \
&&  rm -rf /var/lib/apt/lists/* \
&&  docker-php-ext-configure ldap \
        --with-libdir=lib/x86_64-linux-gnu \
&&  docker-php-ext-install -j $(nproc) \
        ldap \
&&  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps

RUN echo "PHP extension: pgsql pdo_pgsql" \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
        libpq-dev \
&&  docker-php-ext-install -j $(nproc) \
        pgsql \
        pdo_pgsql \
&&  rm -rf /var/lib/apt/lists/*

RUN echo "PHP extension: imagick" \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
        libmagickwand-dev \
&&  rm -rf /var/lib/apt/lists/* \
&&  pecl install \
        imagick \
&&  docker-php-ext-enable \
        imagick

RUN echo "PHP extension: apcu" \
&&  pecl install \
        apcu \
&&  docker-php-ext-enable \
        apcu

RUN echo "PHP extension: mongodb" \
&&  pecl install \
        mongodb \
&&  docker-php-ext-enable \
        mongodb

RUN echo "PHP extension:  xdebug" \
&&  docker-php-ext-install \
        mysqli \
&&  pecl install \
        xdebug \
&&  docker-php-ext-enable \
        xdebug \
&&  echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini

## See http://git.php.net/?p=pecl/php/uploadprogress.git
RUN echo "PHP extension: uploadprogress" \
&&  curl -fsSL 'http://git.php.net/?p=pecl/php/uploadprogress.git;a=snapshot;h=95d8a0fd4554e10c215d3ab301e901bd8f99c5d9;sf=tgz' -o php-uploadprogress.tar.gz \
&&  tar -xzf php-uploadprogress.tar.gz \
&&  rm php-uploadprogress.tar.gz \
&&  (   cd uploadprogress-95d8a0f \
&&      phpize \
&&      ./configure --enable-uploadprogress \
&&      make \
&&      make install \
    ) \
&&  rm -r uploadprogress-95d8a0f \
&&  docker-php-ext-enable uploadprogress



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

RUN echo "Sendmail" \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
        ssmtp \
&&  rm -rf /var/lib/apt/lists/* \
&&  echo 'sendmail_path = /usr/sbin/ssmtp -t' > /usr/local/etc/php/conf.d/mail.ini \
&&  { \
        echo 'mailhub=192.168.99.100:1025'; \
        echo 'FromLineOverride=YES'; \
    } > /etc/ssmtp/ssmtp.conf
#COPY config/ssmtp.conf /etc/ssmtp

## Node.js (latest)
#RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
## Node.js (LTS)
RUN echo "nodejs yarn" \
&&  curl -sL https://deb.nodesource.com/setup_10.x | bash - \
&& apt-get install -y nodejs \
&& npm install -g yarn

RUN echo "System tools" \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
        ghostscript \
        git \
        patch \
        wget \
        curl \
        tar \
        zip \
        unzip \
        vim \
        mc \
&&  rm -rf /var/lib/apt/lists/*

RUN echo "Default data" \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
        git \
&&  git clone https://gitlab.com/vavyskov/webserver-info.git /tmp/webserver-info \
&&  cp -R /tmp/webserver-info/src/. ${DOCUMENT_ROOT} \
&&  rm ${DOCUMENT_ROOT}/index.html \
&&  rm -fr /tmp/webserver-info \
#&&  apt-get purge -y --auto-remove \
#        git \
&&  rm -rf /var/lib/apt/lists/*

## Set permission (33 is the standard uid/gid for "www-data" in Debian)
RUN chown -R 33:33 ${USER_HOME}





## Apache configuration
COPY config/apache-dev.conf /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite expires
#RUN if command -v a2enmod; then a2enmod rewrite;
#RUN if command -v expires; then a2enmod expires;

EXPOSE 80

VOLUME /var/www/html

#WORKDIR /var/www/html
