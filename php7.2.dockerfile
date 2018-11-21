ARG PHP_VERSION="7.2.12-fpm-alpine"
FROM php:${PHP_VERSION}
ARG UID=root
ARG GID=root
ARG USER
ARG XDEBUG_VERSION=2.6.1

# Instalando extensões necessárias do PHP
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

# Instalando o XDebug
RUN pecl install xdebug-${XDEBUG_VERSION}
RUN docker-php-ext-enable xdebug

# Configurando o XDebug
RUN echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Instalando o Git (Composer usa para baixar alguns pacotes)
RUN apk add --update --no-cache git

# Instalando o Composer
RUN php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Setando o user:group do conteiner para o user:group da máquina host (ver arquivo .env e docker-compose.yml)
# Assim, o Composer passa a usar o mesmo user:group do usuário do host
# Configura também as pastas para o novo usuário
RUN chown -R ${UID}:${GID} /var/www/html
RUN chown -R ${UID}:${GID} /root/.composer
RUN mkdir -p /.composer && chown -R ${UID}:${GID} /.composer
RUN mkdir -p /.config && chown -R ${UID}:${GID} /.config
VOLUME /var/www/html
VOLUME /root/.composer
VOLUME /.composer
VOLUME /.config
USER ${UID}
