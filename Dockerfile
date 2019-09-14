FROM php:7.3.0-apache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get update && apt-get install -y git libzip-dev unzip
RUN docker-php-ext-install zip
RUN a2enmod rewrite headers

COPY . /var/www/html