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

RUN mkdir -p /etc/nginx/ssl /var/log/nginx && \
    chown -R www-data:www-data /var/log/nginx /etc/nginx/ssl && \
    chmod -R 755 /var/log/nginx /etc/nginx/ssl && \
    rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY ./conf/hozkaya.conf /etc/nginx/sites-enabled/

RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/ssl.key \
    -out /etc/ssl/certs/ssl.crt \
    -subj "/C=TR/ST=ISTANBUL/L=SARIYER/O=42/CN=hozkaya.42.fr"

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]