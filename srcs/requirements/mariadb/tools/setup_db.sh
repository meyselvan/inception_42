#!/bin/bash
set -euo pipefail

# Environment variables'ı kullan (.env dosyasından)
: ${MYSQL_ROOT_PASSWORD:?"MYSQL_ROOT_PASSWORD environment variable gerekli"}
: ${MYSQL_PASSWORD:?"MYSQL_PASSWORD environment variable gerekli"}
: ${MYSQL_DATABASE:?"MYSQL_DATABASE environment variable gerekli"}
: ${MYSQL_USER:?"MYSQL_USER environment variable gerekli"}

echo "[INFO] MariaDB variables:"
echo "MYSQL_DATABASE: $MYSQL_DATABASE"
echo "MYSQL_USER: $MYSQL_USER"
echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"

# Dizinleri oluştur ve izinleri ayarla
echo "[INFO] Setting up directories and permissions..."
mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql
chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql
chmod -R 755 /var/lib/mysql /run/mysqld /var/log/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[INFO] Initializing database..."
  mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

mysqld --user=mysql &
PID=$!
echo "[INFO] Waiting for MariaDB..."
timeout 30 bash -c 'until mysqladmin ping --silent; do sleep 1; done'

cat > /root/.my.cnf <<EOF
[client]
user=root
password=$MYSQL_ROOT_PASSWORD
EOF
chmod 600 /root/.my.cnf
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"


echo "[INFO] Creating database and user..."
# Create the directory first
mkdir -p /docker-entrypoint-initdb.d
envsubst < /tmp/set.sql > /docker-entrypoint-initdb.d/init.sql
mysql < /docker-entrypoint-initdb.d/init.sql

rm -f /docker-entrypoint-initdb.d/init.sql
kill "$PID"
wait "$PID"

echo "[INFO] MariaDB setup complete."
# Normal modda başlat
exec "$@"