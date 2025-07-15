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

# Dizin ve izin ayarları
echo "Dizin ve izinler ayarlanıyor..."
mkdir -p /var/www/html /run/php /var/log/php
chown -R www-data:www-data /var/www/html /run/php /var/log/php
chmod -R 755 /var/www/html /run/php /var/log/php

# WordPress çalışma dizinine geç
cd /var/www/html

# MariaDB'nin hazır olmasını bekle
echo "MariaDB bağlantısı bekleniyor..."
timeout 60 bash -c '
until nc -z mariadb 3306; do
    echo "MariaDB bağlantısı bekleniyor..."
    sleep 2
done
echo "MariaDB bağlantısı başarılı!"
'

# WordPress indirme ve kurulum
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress kuruluyor..."
    
    # WordPress indir
    wp core download --allow-root || {
        echo "WordPress indirme hatası!"
        exit 1
    }
    
    # wp-config.php oluştur
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb:3306 \
        --dbcharset=utf8mb4 \
        --allow-root || {
        echo "wp-config.php oluşturma hatası!"
        exit 1
    }
    
    # Veritabanı bağlantısını test et
    echo "Veritabanı bağlantısı test ediliyor..."
    wp db check --allow-root || {
        echo "Veritabanı bağlantı hatası!"
        exit 1
    }
    
    # WordPress kurulumu
    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root || {
        echo "WordPress kurulum hatası!"
        exit 1
    }
    
    # Ek kullanıcı oluştur
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --role=author \
        --allow-root || {
        echo "Kullanıcı oluşturma hatası!"
        exit 1
    }
        
    echo "WordPress kurulumu tamamlandı!"
else
    echo "WordPress zaten kurulu."
fi

# Dosya sahipliğini düzelt
chown -R www-data:www-data /var/www/html

# PHP-FPM başlat
echo "PHP-FPM başlatılıyor..."
exec php-fpm7.4 --nodaemonize
