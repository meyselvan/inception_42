#!/bin/bash

set -e

# mkdir -p /run/php

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress setting up.."

    echo "Testing MariaDB connection..."
    until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
        echo "Waiting for MariaDB connection..."
        sleep 2
    done

    echo "MariaDB connection successful!"

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

    echo "WordPress setup completed!"
else
    echo "WordPress is already installed."
fi

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "PHP-FPM starting..."
exec "$@"
