FROM php:8.0-fpm-alpine3.13

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
ADD ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-x-01-custom-params.ini

RUN apk update

RUN set -x \
  && apk add git \
  libxml2-dev \
  libressl-dev \
  oniguruma-dev \
  bzip2-dev \
  nginx \
  nginx-mod-http-headers-more \
  curl \
  curl-dev \
  ca-certificates \
  runit \
  ghostscript \
  imagemagick \
  imagemagick-libs \
  imagemagick-dev \
  postgresql-dev \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

RUN apk add --update libzip-dev libmcrypt-dev libpng-dev libjpeg-turbo-dev libxml2-dev icu-dev curl-dev

RUN apk add --update --virtual build-dependencies build-base gcc wget autoconf

RUN docker-php-ext-install \
  bcmath \
  bz2 \
  calendar \
  exif \
  opcache \
  pdo_mysql \
  pdo_pgsql \
  shmop \
  sockets \
  sysvmsg \
  sysvsem \
  sysvshm \
  zip

RUN set -xe \
  && pecl install imagick \
  && docker-php-ext-enable --ini-name 20-imagick.ini imagick

RUN mkdir /run/nginx

COPY ./src /

WORKDIR /app

RUN chmod +x \
  /sbin/runit-wrapper \
  /sbin/runsvdir-start \
  /etc/service/nginx/run \
  /etc/service/php-fpm/run

EXPOSE 80

CMD ["/sbin/runit-wrapper"]
