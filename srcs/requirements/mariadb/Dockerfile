FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        gettext \
        mariadb-client \
        mariadb-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /docker-entrypoint-initdb.d && \
    chown -R mysql:mysql /run/mysqld

COPY ./conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.conf
COPY ./tools/db_init.sql /tmp/set.sql
COPY ./tools/setup_db.sh /usr/local/bin/config.sh

RUN chmod +x /usr/local/bin/config.sh

EXPOSE 3306

CMD ["/usr/local/bin/config.sh"]
