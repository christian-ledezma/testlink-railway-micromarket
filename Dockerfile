# Imagen oficial de Bitnami TestLink
FROM bitnami/testlink:latest

# Credenciales iniciales (puedes cambiarlas luego dentro de la app)
ENV TESTLINK_USERNAME=admin
ENV TESTLINK_PASSWORD=admin123
ENV TESTLINK_EMAIL=admin@example.com