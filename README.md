# php-dockerfiles
Dockerfiles for every PHP version, Frameworks and situations

## mlalbuquerque/php-containers
Collection of PHP-based containers for all kinds of use.
The default tag (`latest`) points to PHP 7.2 (based on `php:7.2.12-fpm-alpine` container) with:
 - XDebug 2.6.1
 - Git
 - Composer

### Available Tags
 - `latest` - see above
 - `7.2` - same as `latest`
 - `7.1` - PHP 7.1 (based on `php:7.1.24-fpm-alpine` container) with:
    - XDebug 2.5.5
    - Git
    - Composer
- `7.2-tools` - same as `7.2`, but with more tools:
    - PHPUnit 7
    - PHP CS
    - PHPMD
    - PHP Stan
- `tools` - same as `7.2-tools`
- `laravel` - same as `7.2-tools`, but with Laravel Installer
- `7.2-laravel` - same as `laravel`

### Using the containers
Runnig on shell:
```Shell
$ docker run --name my-php-ocntainer -v ${PWD}:/var/www/html -p "8000:8000" mlalbuquerque/php-containers:latest
```
And if you want to use the **Embedded Server**, you can run the following command (look I'm mapping host port `8000` to container port `8000`):
```Shell
$ docker exec -it my-php-container php -S 0.0.0.0:8000 -t /var/www/html
```
Then access http://localhost:8000/

Running on Docker Compose with Apache:

`docker-compose.yml`
```YAML
version: "3"

services: 

  webserver:
    image: webdevops/apache:latest
    ports:
      - 80:80
      - 443:443
    volumes: 
      - .:/var/www/html
    environment:
      WEB_PHP_SOCKET: "php:9000"
      WEB_PHP_TIMEOUT: 600
      WEB_DOCUMENT_ROOT: "/var/www/html"
  
  php:
    image: mlalbuquerque/php-containers:latest
    volumes: 
        - .:/var/www/html
```

Running on Docker Compose with Embedded Server:

`docker-compose.yml`
```YAML
version: "3"

services: 

  php:
    image: mlalbuquerque/php-containers:latest
    volumes: 
        - .:/var/www/html
    command: php -S 0.0.0.0:8000
```

Then, to run both:
```Shell
$ docker-compose up -d
```