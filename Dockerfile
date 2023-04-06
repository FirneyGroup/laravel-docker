## 
## PHP8-PHP
## 
FROM --platform=linux/amd64 php:8.2-fpm-alpine as php8-php

#log php errors to stderr
RUN ln -sf /dev/stderr /var/log/php-error.log

# install the PHP extensions we need
RUN set -ex \
	&& apk add --no-cache --virtual .build-deps \
    coreutils \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    postgresql-dev \
    $PHPIZE_DEPS \
  && docker-php-ext-configure \
  	gd --enable-gd --with-freetype --with-jpeg \
  && docker-php-ext-configure zip \
	&& docker-php-ext-install -j "$(nproc)" \
    exif \
    gd \
    opcache \
    zip \
    pdo_mysql \
    pdo_pgsql \
    mysqli \
    pcntl \
    bcmath \
  && pecl channel-update pecl.php.net \
	&& pecl install -o -f redis \
	&& docker-php-ext-enable redis \
	&& runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
	&& apk add --virtual .drupal-phpexts-rundeps $runDeps \
	&& apk del .build-deps \
	&& rm -rf /tmp/pear
COPY php/opcache.ini php/php.ini /usr/local/etc/php/conf.d/
COPY php/www.conf /usr/local/etc/php-fpm.d/


##
## Composer
##
FROM --platform=linux/amd64 composer:latest as composer
RUN apk add --no-cache bash
COPY src /var/www/app
WORKDIR /var/www/app
RUN composer install


##
## Laravel & Artisan
##
FROM --platform=linux/amd64 php8-php as laravel
COPY php/dev.ini /usr/local/etc/php/conf.d/
COPY --from=composer --chown=www-data:www-data /var/www/app /var/www/app
WORKDIR /var/www/app


##
## NGINX
##
FROM --platform=linux/amd64 nginx:1.21.6-alpine as nginx
COPY nginx/conf.d /etc/nginx/conf.d
COPY nginx/include /etc/nginx/include
COPY nginx/nginx.conf /etc/nginx/
COPY --from=laravel --chown=root:nginx /var/www/app /var/www/app
COPY nginx/nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh
COPY nginx/nginx-entrypoint.dev.sh /usr/local/bin/nginx-entrypoint.dev.sh
RUN chmod +x /usr/local/bin/nginx-entrypoint*
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.dev.sh"]
CMD ["nginx", "-g", "daemon off;"]


##
## MySQL (Mariadb)
##
FROM arm64v8/mariadb:10.7
COPY init.dev.sql /docker-entrypoint-initdb.d/init.dev.sql


##
## Redis
##
FROM arm64v8/redis:5-alpine