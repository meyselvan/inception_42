FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        iputils-ping \
        nginx \
        openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Nginx dizinlerini oluştur ve varsayılan siteleri kaldır
RUN mkdir -p /etc/nginx/ssl /var/log/nginx /var/www/html && \
    chown -R www-data:www-data /var/log/nginx /etc/nginx/ssl /var/www/html && \
    chmod -R 755 /var/log/nginx /etc/nginx/ssl /var/www/html && \
    rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Server konfigürasyonunu kopyala
COPY conf/server.conf /etc/nginx/sites-enabled/

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# SSL sertifikası oluştur
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/ssl.key \
    -out /etc/ssl/certs/ssl.crt \
    -subj "/C=TR/ST=ISTANBUL/L=SARIYER/O=42/CN=relvan.42.fr" && \
    chmod 600 /etc/ssl/private/ssl.key && \
    chmod 644 /etc/ssl/certs/ssl.crt

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]