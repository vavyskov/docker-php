ARG PHP_VERSION=7.2

FROM php:${PHP_VERSION:+${PHP_VERSION}-}apache-stretch

ENV USER_HOME=/var/www
#ENV DOCUMENT_ROOT=/var/www/html/public
ENV DOCUMENT_ROOT=/var/www/html

## PHP extensions
## https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
## https://www.drupal.org/docs/8/system-requirements/php-requirements#extensions
RUN savedAptMark="$(apt-mark showmanual)" \
&&	apt-get update \
&&	apt-get install -y --no-install-recommends \
        ## php-zip
        libzip-dev \
        ## php-gd
        libfreetype6-dev \
        libpng-dev \
        ## php-intl
        zlib1g-dev \
        libicu-dev \
        g++ \
        ## php-pgsql
        libpq-dev \
        ## php-ldap
        libldap2-dev \
        ## php-imagick
        libmagickwand-dev \
        ## ???
        #libjpeg-dev \
##&& docker-php-ext-configure zip
##        --with-libzip \
&&  docker-php-ext-configure gd \
        --with-freetype-dir=/usr \
        --with-jpeg-dir=/usr \
        --with-png-dir=/usr \
&&  docker-php-ext-configure ldap \
        --with-libdir=lib/x86_64-linux-gnu \
&&  docker-php-ext-install -j $(nproc) \
        zip \
        gd \
        intl \
        pdo_pgsql \
        ldap \
        bcmath \
        exif \
        mysqli \
        pdo_mysql \
        opcache \
&&  pecl install \
        imagick \
        mongodb \
        apcu \
        xdebug \
&&  docker-php-ext-enable \
        imagick \
        mongodb \
        apcu \
        xdebug \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
&&  apt-mark auto '.*' > /dev/null \
&&	apt-mark manual $savedAptMark \
&&	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual \
&&  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
&&  rm -rf /var/lib/apt/lists/*

## Build and install the Uploadprogress PHP extension.
## See http://git.php.net/?p=pecl/php/uploadprogress.git
RUN curl -fsSL 'http://git.php.net/?p=pecl/php/uploadprogress.git;a=snapshot;h=95d8a0fd4554e10c215d3ab301e901bd8f99c5d9;sf=tgz' -o php-uploadprogress.tar.gz \
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

# Set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

## Configure error logging
RUN { \
        echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
        echo 'display_errors = Off'; \
        echo 'display_startup_errors = Off'; \
        echo 'log_errors = On'; \
        echo 'error_log = /dev/stderr'; \
        echo 'log_errors_max_len = 1024'; \
        echo 'ignore_repeated_errors = On'; \
        echo 'ignore_repeated_source = Off'; \
        echo 'html_errors = Off'; \
    } > /usr/local/etc/php/conf.d/error-logging.ini

RUN a2enmod rewrite expires
#RUN if command -v a2enmod; then a2enmod rewrite;
#RUN if command -v expires; then a2enmod expires;

## Sendmail
RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
        ssmtp \
&&  rm -rf /var/lib/apt/lists/* \
&&  echo 'sendmail_path = /usr/sbin/ssmtp -t' > /usr/local/etc/php/conf.d/mail.ini
COPY config/ssmtp.conf /etc/ssmtp

## Apache configuration
ENV DOCUMENT_ROOT=/var/www/html/public
COPY config/apache-dev.conf /etc/apache2/sites-available/000-default.conf

## Copy default data
COPY config/public ${DOCUMENT_ROOT}

## Set permission (33 is the standard uid/gid for "www-data" in Debian)
RUN chown -R 33:33 ${USER_HOME}



## Composer (get path command: which composer)
#COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer



EXPOSE 80

VOLUME /var/www/html

#WORKDIR /var/www/html
