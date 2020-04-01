# docker-php

Supported tags and respective `Dockerfile` links:

- [`7.4-fpm-ssh-alpine3.11`](https://github.com/vavyskov/docker-php/tree/master/alpine3.11/fpm-ssh)
- [`7.4-fpm-alpine3.11`](https://github.com/vavyskov/docker-php/tree/master/alpine3.11/fpm)
- [`7.4-apache-buster`](https://github.com/vavyskov/docker-php/tree/master/buster/apache)
- [`7.3-fpm-alpine3.11`](https://github.com/vavyskov/docker-php/tree/master/alpine3.11/fpm)
- [`7.3-fpm-alpine3.10`](https://github.com/vavyskov/docker-php/tree/master/alpine3.10/fpm)
- [`7.3-apache-buster`](https://github.com/vavyskov/docker-php/tree/master/buster/apache)
- [`7.3-apache-stretch`](https://github.com/vavyskov/docker-php/tree/master/stretch/apache)
- [`7.2-fpm-alpine3.10`](https://github.com/vavyskov/docker-php/tree/master/alpine3.10/fpm)
- [`7.2-apache-stretch`](https://github.com/vavyskov/docker-php/tree/master/stretch/apache)

Extensions:

- mysqli
- pdo_mysql
- opcache
- exif
- bcmath
- gd
- zip
- intl
- ldap
- pgsql
- pdo_pgsql
- imagick
- apcu
- mongodb
- xdebug
- uploadprogress

Other:

- composer
- sendmail: ssmtp (msmtp - buster/apache)
- nodejs
- yarn

System tools:

- ghostscript

---

ToDo

- Change variable notation by "alpine.3.11/fpm-ssh"
- Sendmail IP and port as variables:
    - [x] alpine3.11/fpm-ssh
    - [ ] alpine3.11/fpm, alpine3.10, buster, stretch
- Docker image mode (dev | prod):
    - [x] alpine3.11/fpm-ssh
    - [ ] alpine3.11/fpm, alpine3.10, buster, stretch
- [msmtp](https://wiki.alpinelinux.org/wiki/Relay_email_to_gmail_(msmtp,_mailx,_sendmail)

Tips:

- [build options](https://hub.docker.com/r/llaumgui/php/dockerfile)
- [PHP packages](https://hub.docker.com/r/wodby/drupal-php/dockerfile/)
- [other tips](https://hub.docker.com/r/aexchecker/docker-php/dockerfile/)