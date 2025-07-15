#!/bin/bash

# Dizin ve izin ayarları
echo "Dizin ve izinler ayarlanıyor..."
mkdir -p /var/www/html /run/php /var/log/php
chown -R www-data:www-data /var/www/html /run/php /var/log/php
chmod -R 755 /var/www/html /run/php /var/log/php

# WordPress çalışma dizinine geç
cd /var/www/html

# MariaDB'nin hazır olmasını bekle
echo "MariaDB bağlantısı bekleniyor..."
timeout 60 bash -c 'until mysqladmin ping -h mariadb --silent; do sleep 2; done' || {
    echo "MariaDB bağlantısı başarısız!"
    exit 1
}

# WordPress indirme ve kurulum
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress kuruluyor..."
    
    # WordPress indir
    wp core download --allow-root
    
    # wp-config.php oluştur
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb:3306 \
        --dbcharset=utf8mb4 \
        --allow-root
    
    # WordPress kurulumu
    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
    
    # Ek kullanıcı oluştur
    wp user create $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --role=author \
        --allow-root
        
    echo "WordPress kurulumu tamamlandı!"
else
    echo "WordPress zaten kurulu."
fi

# Dosya sahipliğini düzelt
chown -R www-data:www-data /var/www/html

# PHP-FPM başlat
echo "PHP-FPM başlatılıyor..."
exec php-fpm7.4 --nodaemonize
