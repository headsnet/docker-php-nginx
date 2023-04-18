ARG NAME_IMAGE_BASE='php'
ARG NAME_IMAGE_TAG='8.1-fpm-alpine3.17'

FROM ${NAME_IMAGE_BASE}:${NAME_IMAGE_TAG}

ARG BUILD_ID="unknown"
ARG COMMIT_ID="unknown"
ARG VERSION_OS='3.17'
ARG VERSION_PHP='8.1'

LABEL \
    ALPINE="$VERSION_OS" \
    BUILD_ID="$BUILD_ID" \
    COMMIT_ID="$COMMIT_ID" \
    MAINTAINER='Samuel Fontebasso <samuel.txd@gmail.com>' \
    PHP_VERSION="$VERSION_PHP"

COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

RUN set -ex; \
    apk add --no-cache --upgrade  \
        icu-data-full \
        nginx \
        nginx-mod-http-headers-more \
        oniguruma-dev \
        runit; \
    install-php-extensions \
        bcmath \
        gd \
        imap \
        intl \
        mailparse \
        pdo_mysql \
        redis \
        tidy \
        xsl \
        zip; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini";

# Copy service configuration files into the image
COPY ./src /

# This file allows customisations to PHP.ini
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-02-custom-params.ini

RUN chmod +x \
   /sbin/runit-wrapper \
   /sbin/runsvdir-start \
   /etc/service/nginx/run \
   /etc/service/php-fpm/run

WORKDIR /app
EXPOSE 80/tcp

CMD ["/sbin/runit-wrapper"]
