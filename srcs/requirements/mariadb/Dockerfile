FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        gettext \
        mariadb-client \
        mariadb-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql && \
    chmod -R 755 /run/mysqld /var/lib/mysql /var/log/mysql

COPY ./conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.conf
COPY ./tools/db_init.sql /tmp/set.sql
COPY ./tools/setup_db.sh /usr/local/bin/config.sh

RUN chmod +x /usr/local/bin/config.sh

EXPOSE 3306

CMD ["/usr/local/bin/config.sh"]
