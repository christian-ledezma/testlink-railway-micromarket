FROM php:8.1-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev && \
    docker-php-ext-install mysqli gd && \
    docker-php-ext-enable mysqli

# Descargar TestLink desde GitHub
RUN git clone https://github.com/TestLinkOpenSourceTRMS/testlink-code.git /var/www/html/testlink

# Ajustar permisos
RUN chown -R www-data:www-data /var/www/html/testlink

# Establecer el directorio de trabajo
WORKDIR /var/www/html/testlink

EXPOSE 80
