#!/bin/bash

set -e

echo "Environment variables kontrol ediliyor..."
: ${DOMAIN_NAME:?"DOMAIN_NAME environment variable gerekli"}
: ${MYSQL_DATABASE:?"MYSQL_DATABASE environment variable gerekli"}
: ${MYSQL_USER:?"MYSQL_USER environment variable gerekli"}
: ${MYSQL_PASSWORD:?"MYSQL_PASSWORD environment variable gerekli"}
: ${MYSQL_ROOT_PASSWORD:?"MYSQL_ROOT_PASSWORD environment variable gerekli"}
: ${WP_TITLE:?"WP_TITLE environment variable gerekli"}
: ${WP_ADMIN_USER:?"WP_ADMIN_USER environment variable gerekli"}
: ${WP_ADMIN_PASSWORD:?"WP_ADMIN_PASSWORD environment variable gerekli"}
: ${WP_ADMIN_EMAIL:?"WP_ADMIN_EMAIL environment variable gerekli"}
: ${WP_USER:?"WP_USER environment variable gerekli"}
: ${WP_USER_EMAIL:?"WP_USER_EMAIL environment variable gerekli"}
: ${WP_USER_PASSWORD:?"WP_USER_PASSWORD environment variable gerekli"}

echo "Tüm environment variables mevcut."

mkdir -p /run/php

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress kuruluyor..."

    echo "MariaDB bağlantısı test ediliyor..."
    until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
        echo "Waiting for MariaDB connection..."
        sleep 2
    done
    
    echo "MariaDB bağlantısı başarılı!"
    
    wp core download --path=/var/www/html --allow-root

    wp config create --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    wp core install --path=/var/www/html \
        --url=${WP_URL} \
        --title="${WP_TITLE}" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    wp user create --path=/var/www/html \
        ${WP_USER} ${WP_USER_EMAIL} \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
    
    chmod 600 /var/www/html/wp-config.php
        
    echo "WordPress kurulumu tamamlandı!"
else
    echo "WordPress zaten kurulu."
fi

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# PHP-FPM başlat
echo "PHP-FPM başlatılıyor..."
exec "$@"
