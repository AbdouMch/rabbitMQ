ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.14

### PHP
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS symfony_php

# persistent / runtime deps
RUN apk add --no-cache \
        acl \
        bash \
        curl \
        dbus \
        fcgi \
        file \
        fontconfig \
        freetype \
        g++ \
        gettext \
        git \
        jq \
        libjpeg-turbo \
        libpng \
        make \
        nodejs \
        npm \
        oniguruma-dev \
        openssh \
        rabbitmq-c-dev \
        ttf-freefont \
        wkhtmltopdf \
    ;

ENV APCU_VERSION 5.1.18
ENV AMQP_VERSION 1.9.4
RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        zlib-dev \
    ; \
    docker-php-ext-install -j$(nproc) \
        calendar \
        gd \
        intl \
        mbstring \
        pcntl \
        pdo_mysql \
        soap \
        tokenizer \
        zip \
    ; \
    pecl install \
        amqp-${AMQP_VERSION} \
        apcu-${APCU_VERSION} \
        xdebug \
    ; \
    pecl clear-cache; \
    docker-php-ext-enable \
        amqp \
        apcu \
        opcache \
        xdebug \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .phpexts-rundeps $runDeps; \
    apk del .build-deps

RUN echo "@3.8 http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories && \
    echo "@3.8community http://dl-cdn.alpinelinux.org/alpine/v3.8/community" >> /etc/apk/repositories && \
    apk update && \
    apk add pdftk@3.8community \
        libgcj@3.8 \
        imagemagick \
        texlive

COPY php.ini /usr/local/etc/php/php.ini
RUN php -r "echo ini_get('memory_limit').PHP_EOL;"
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /srv/app

COPY docker-entrypoint.sh /usr/local/bin/docker-app-entrypoint
RUN chmod +x /usr/local/bin/docker-app-entrypoint

RUN set -eux; \
        mkdir -p /public/exports var/cache var/logs var/sessions

ENTRYPOINT ["docker-app-entrypoint"]
CMD ["php-fpm"]
