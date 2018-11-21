ARG PHP_VERSION="7.2.12-fpm-alpine"
FROM php:${PHP_VERSION}
ARG UID=root
ARG GID=root
ARG USER
ARG XDEBUG_VERSION=2.6.1

# Installing needed extensions
RUN apk add --update --no-cache \
        alpine-sdk autoconf curl curl-dev freetds-dev \
        libxml2-dev jpeg-dev openldap-dev libmcrypt-dev \
        libpng-dev libxslt-dev postgresql-dev
RUN docker-php-ext-configure ldap --with-ldap=/usr
RUN docker-php-ext-configure xml --with-libxml-dir=/usr
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-png-dir=/usr/include
RUN docker-php-ext-install \
    bcmath calendar curl dom fileinfo gd hash json ldap mbstring \
    mysqli pgsql pdo pdo_dblib pdo_mysql pdo_pgsql sockets xml xsl zip

# Installing XDebug
RUN pecl install xdebug-${XDEBUG_VERSION}
RUN docker-php-ext-enable xdebug

# Configuring XDebug
RUN echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Installing Git (Composer uses it - so can you, if you don't want to install on the host)
RUN apk add --update --no-cache git

# Installing Composer
RUN php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
ENV PATH "${PATH}:/root/.composer/vendor/bin"

# Installing Tools (PHPUnit, Code Sniffer, PHP MD, PHP Stan)
RUN composer global require phpunit/phpunit ^7 
RUN composer global require squizlabs/php_codesniffer
RUN composer global require phpmd/phpmd
RUN composer global require phpstan/phpstan
# Try one of these for PHP Documentation Generation:
# phpDocumentor - https://www.phpdoc.org/
# phpDox - http://phpdox.de/
# Docblox - https://github.com/dzuelke/Docblox
# ApiGen - https://github.com/ApiGen/ApiGen

# Setting conteiner's user:group same as host's user:group (see .env file and docker-composer.yml)
# So, Composer uses the host's user's user:group
# Also configure the user's folders
RUN chown -R ${UID}:${GID} /var/www/html
RUN chown -R ${UID}:${GID} /root/.composer
USER ${UID}