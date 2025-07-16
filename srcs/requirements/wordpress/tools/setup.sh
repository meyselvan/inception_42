#!/bin/bash

# Environment variables kontrolü
echo "Environment variables kontrol ediliyor..."
: ${MYSQL_DATABASE:?"MYSQL_DATABASE environment variable gerekli"}
: ${MYSQL_USER:?"MYSQL_USER environment variable gerekli"}
: ${MYSQL_PASSWORD:?"MYSQL_PASSWORD environment variable gerekli"}
: ${DOMAIN_NAME:?"DOMAIN_NAME environment variable gerekli"}
: ${WP_TITLE:?"WP_TITLE environment variable gerekli"}
: ${WP_ADMIN_USER:?"WP_ADMIN_USER environment variable gerekli"}
: ${WP_ADMIN_PASSWORD:?"WP_ADMIN_PASSWORD environment variable gerekli"}
: ${WP_ADMIN_EMAIL:?"WP_ADMIN_EMAIL environment variable gerekli"}
: ${WP_USER:?"WP_USER environment variable gerekli"}
: ${WP_USER_EMAIL:?"WP_USER_EMAIL environment variable gerekli"}
: ${WP_USER_PASSWORD:?"WP_USER_PASSWORD environment variable gerekli"}

echo "Tüm environment variables mevcut."

mkdir -p /run/php

# WordPress indirme ve kurulum
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress kuruluyor..."

    until mysql -h mariadb -u ${MYSQL_USER} -p"$(cat /run/secrets/db_pass)" -e "SELECT 1;" >/dev/null 2>&1; do
        echo "Waiting for MariaDB connection..."
        sleep 2
    done
    
    wp core download --path=/var/www/html --allow-root

    # Create wp-config.php using variables from .env and secrets
    wp config create --path=/var/www/html \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass="$(cat /run/secrets/db_pass)" \
        --dbhost=${DB_HOST} \
        --allow-root

    # Install WordPress
    wp core install --path=/var/www/html \
        --url=${WP_URL} \
        --title="${WP_TITLE}" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password="$(cat /run/secrets/wp_admin_pass)" \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    # Create the second, non-admin user
    wp user create --path=/var/www/html \
        ${WP_USER} ${WP_EMAIL} \
        --role=author \
        --user_pass="$(cat /run/secrets/wp_user_pass)" \
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
