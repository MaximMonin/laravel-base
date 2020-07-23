FROM php:7.4-fpm

# Install tools required for build production server
RUN apt-get update \
 && apt-get install -fyqq --no-install-recommends \
    bash curl wget rsync ca-certificates openssl openssh-client git libxml2-dev libcurl4-gnutls-dev\
    imagemagick gcc make autoconf libc-dev pkg-config libmagickwand-dev \
# Install additional PHP libraries
&&  docker-php-ext-install \
    pcntl \
    bcmath \
    sockets \
    soap \
    opcache \
    intl \
# Install mysql plugin
&&  apt-get update \
 && apt-get install -fyqq mariadb-client libmariadbclient-dev \
 && docker-php-ext-install pdo_mysql mysqli \
 && apt-get remove -fyqq libmariadbclient-dev \
# Install pgsql plugin
&& apt-get update \
 && apt-get install -fyqq postgresql-client libpq-dev \
 && docker-php-ext-install pdo_pgsql pgsql \
 && apt-get remove -fyqq libpq-dev \
# Install libraries for compiling GD, then build it
&& apt-get update \
 && apt-get install -fyqq libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev libpng16-16 libjpeg62-turbo libjpeg62-turbo-dev \
 && docker-php-ext-install gd \
 && apt-get remove -fyqq libfreetype6-dev libpng-dev libjpeg62-turbo-dev \
# Add ZIP archives support
&& apt-get update \
 && apt-get install -fyqq zip libzip-dev \
 && docker-php-ext-install zip \
 && apt-get remove -fyqq libzip-dev \
# Install memcache
&& apt-get update \
 && apt-get install -fyqq libmemcached11 libmemcached-dev \
 && pecl install memcached \
 && docker-php-ext-enable memcached \
 && apt-get remove -fyqq libmemcached-dev \
# Install redis ext
&& pecl install redis \
 && docker-php-ext-enable redis \
# Install xdebug pecl_http imagick
&& pecl channel-update pecl.php.net && pecl install xdebug \
 && pecl install raphf propro \
 && docker-php-ext-enable raphf propro \
 && pecl install pecl_http \
 && echo extension=http.so > /usr/local/etc/php/conf.d/docker-php-ext-http.ini \
 && apt install libmagickwand-dev -y && echo '' | pecl install imagick && echo extension=imagick.so > /usr/local/etc/php/conf.d/imagick.ini \
# Install composer
&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && chmod 755 /usr/bin/composer \
# Autoclean
 && apt-get autoclean -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/pear/ \
 && apt-get remove libgmp-dev libgnutls28-dev libhashkit-dev libidn2-dev libmariadb-dev libp11-kit-dev libsasl2-dev libtasn1-6-dev nettle-dev -y \
 && apt-get update && apt upgrade -y && apt-get install procps -y

# Install supervisor, cron, ssmtp mail
RUN apt install supervisor cron -y \
    && echo 'deb http://deb.debian.org/debian stretch main' >> /etc/apt/sources.list \
    && apt update && apt install ssmtp -y && chfn -f "Laravel" root && chfn -f "Laravel" www-data && chmod -R a+r /etc/ssmtp \
    && mkdir /app

ADD image/start.sh /

# Install your laravel application here
