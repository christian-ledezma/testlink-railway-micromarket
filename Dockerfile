FROM php:8.1-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev && \
    docker-php-ext-install mysqli gd && \
    docker-php-ext-enable mysqli

# Descargar TestLink desde GitHub
RUN git clone https://github.com/TestLinkOpenSourceTRMS/testlink-code.git /var/www/html/testlink

# Cambiar el DocumentRoot de Apache a la carpeta de TestLink
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/testlink\n\
    <Directory /var/www/html/testlink>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Dar permisos a www-data
RUN chown -R www-data:www-data /var/www/html/testlink

# Habilitar mod_rewrite (TestLink lo usa)
RUN a2enmod rewrite

# Establecer el directorio de trabajo
WORKDIR /var/www/html/testlink

EXPOSE 80
