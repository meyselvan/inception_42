# MariaDB bir veritabanı sunucusudur.
# WordPress gibi uygulamalar için veri depolar.
# Bu dosya, MariaDB başlatılırken çalıştırılacak SQL komutlarını içerir.
# Bu komutlar, veritabanı ve kullanıcı oluşturma işlemlerini yapar.
# WordPress için gerekli veritabanı ve kullanıcıyı oluşturur.
# Database oluşturur ve mariadb ile wordpress arasındaki bağlantıyı sağlaması için kullanıcı yetkilendirir.
# Bu kullanıcı WordPress uygulamasının veritabanına erişmesini sağlar.

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
