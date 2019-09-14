FROM php:7.3.8-apache

# fish
RUN FISH_VERSION="3.0.2" \
    && apt-get update \
    && apt-get install -y libncurses5-dev \
    && curl -OSLs "https://github.com/fish-shell/fish-shell/releases/download/$FISH_VERSION/fish-$FISH_VERSION.tar.gz" \
    && tar -xzf "fish-$FISH_VERSION.tar.gz" \
    && cd "fish-$FISH_VERSION" \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -rf "fish-$FISH_VERSION" "fish-$FISH_VERSION.tar.gz" \
    && fish -c true
RUN mkdir -p /var/www/.config/fish \
    && chown -R www-data:www-data /var/www/.config/fish \
    && mkdir -p /var/www/.local/share/fish \
    && chown -R www-data:www-data /var/www/.local/share/fish

RUN apt-get update \
    && apt-get install -y git libzip-dev zlib1g-dev unzip

# core extensions
RUN docker-php-ext-enable opcache
RUN docker-php-ext-install bcmath \
    && docker-php-ext-install zip

# intl
RUN apt-get update \
    && apt-get install -y libicu-dev \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-install intl

# pdo_pgsql
RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql

# memcached
RUN apt-get update \
    && apt-get install -y libmemcached-dev zlib1g-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached

# gd
## patch is needed for latest PHP 7.3 versions.
## this should be fixed in PHP 7.4
## see https://github.com/docker-library/php/issues/865
RUN apt-get update && apt-get install -y pkg-config patch
ADD https://git.archlinux.org/svntogit/packages.git/plain/trunk/freetype.patch?h=packages/php /tmp/freetype.patch
RUN docker-php-source extract; \
    cd /usr/src/php; \
    patch -p1 -i /tmp/freetype.patch; \
    rm /tmp/freetype.patch

RUN apt-get update \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# amqp
RUN apt-get update \
    && apt-get install -y librabbitmq-dev \
    && pecl install amqp \
    && docker-php-ext-enable amqp

# imagick
RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagickwand-dev imagemagick \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# xdebug
# we do not enable by default the extension
# this can be done in php/php-ini-overrides.ini when needed in order improve performance when not debuging
RUN pecl install xdebug-2.7.2

# pdftotext
RUN apt-get update \
    && apt-get install -y poppler-utils

# composer
ENV COMPOSER_MEMORY_LIMIT=-1
ENV COMPOSER_HOME /var/www/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer global require hirak/prestissimo
RUN composer global require maglnet/composer-require-checker
RUN chown -R www-data:www-data $COMPOSER_HOME
ENV PATH "${PATH}:/var/www/composer/vendor/bin"

# setup apache
RUN a2enmod rewrite
RUN a2enmod headers
ENV APACHE_DOCUMENT_ROOT /durchblicke/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Nodejs
ENV NODE_VERSION 12.7.0
RUN ARCH="x64" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs
RUN npm install -g mjml@4.3.1

RUN usermod -u 1000 www-data
RUN ln -s /durchblicke/bin/console /bin/durchblicke

WORKDIR /durchblicke
