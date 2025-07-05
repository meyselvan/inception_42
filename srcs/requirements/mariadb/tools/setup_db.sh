#!/bin/bash
set -euo pipefail

export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password 2>/dev/null || echo "default_root_pass")
export MYSQL_PASSWORD=$(cat /run/secrets/mysql_password 2>/dev/null || echo "default_user_pass")
export MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}
export MYSQL_USER=${MYSQL_USER:-relvan}

# Dizinleri oluştur ve izinleri ayarla
echo "[INFO] Setting up directories and permissions..."
mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql
chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql
chmod -R 755 /var/lib/mysql /run/mysqld /var/log/mysql

# Veritabanını başlat (eğer yoksa)
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[INFO] Initializing database..."
  mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# MariaDB'yi geçici olarak başlat
echo "[INFO] Starting MariaDB temporarily..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
PID=$!

# MariaDB'nin başlamasını bekle
echo "[INFO] Waiting for MariaDB..."
timeout 30 bash -c 'until mysqladmin ping --silent; do sleep 1; done'

# Root şifresini ayarla
echo "[INFO] Setting root password..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

# Veritabanı ve kullanıcı oluştur
echo "[INFO] Creating database and user..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
"

# Geçici MariaDB'yi durdur
echo "[INFO] Stopping temporary MariaDB..."
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait "$PID"

echo "[INFO] MariaDB setup complete. Starting normally..."
# Normal modda başlat
exec mysqld --user=mysql --console