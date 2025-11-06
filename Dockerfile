FROM php:8.1-apache

# Instalar dependencias necesarias y cliente MySQL
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev default-mysql-client && \
    docker-php-ext-install mysqli gd && \
    docker-php-ext-enable mysqli

# Descargar TestLink desde GitHub
RUN git clone https://github.com/TestLinkOpenSourceTRMS/testlink-code.git /var/www/html/testlink

# Crear directorios requeridos por TestLink
RUN mkdir -p /var/testlink/logs && \
    mkdir -p /var/testlink/upload_area && \
    chown -R www-data:www-data /var/testlink

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

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Script de inicio que configura la BD y ejecuta SQL pendiente
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Esperar a que MySQL esté listo\n\
echo "Esperando conexión a MySQL..."\n\
until mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "SELECT 1" > /dev/null 2>&1; do\n\
  echo "MySQL no está listo, reintentando..."\n\
  sleep 3\n\
done\n\
echo "Conexión a MySQL exitosa!"\n\
\n\
# Crear archivo de configuración con variables de entorno\n\
CONFIG_FILE="/var/www/html/testlink/config_db.inc.php"\n\
echo "Generando archivo de configuración..."\n\
cat > "$CONFIG_FILE" <<EOF\n\
<?php\n\
define("DB_TYPE", "mysql");\n\
define("DB_HOST", "${DB_HOST}");\n\
define("DB_PORT", "${DB_PORT}");\n\
define("DB_NAME", "${DB_NAME}");\n\
define("DB_USER", "${DB_USER}");\n\
define("DB_PASS", "${DB_PASS}");\n\
define("DB_TABLE_PREFIX", "tl_");\n\
?>\n\
EOF\n\
chown www-data:www-data "$CONFIG_FILE"\n\
chmod 644 "$CONFIG_FILE"\n\
echo "Archivo de configuración creado."\n\
\n\
# Ejecutar script UDF si existe y no se ha ejecutado antes\n\
if [ -f /var/www/html/testlink/install/sql/mysql/testlink_create_udf0.sql ] && [ ! -f /var/testlink/.udf_installed ]; then\n\
  echo "Ejecutando script UDF..."\n\
  mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < /var/www/html/testlink/install/sql/mysql/testlink_create_udf0.sql 2>/dev/null || true\n\
  touch /var/testlink/.udf_installed\n\
  echo "Script UDF ejecutado."\n\
fi\n\
\n\
# Iniciar Apache\n\
echo "Iniciando Apache..."\n\
exec apache2-foreground\n\
' > /usr/local/bin/start.sh && \
    chmod +x /usr/local/bin/start.sh

# Establecer el directorio de trabajo
WORKDIR /var/www/html/testlink

EXPOSE 80

# Usar el script de inicio personalizado
CMD ["/usr/local/bin/start.sh"]