FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    php7.4-fpm \
    php7.4-mysql \
    mariadb-server \
    mariadb-client \
    gettext-base \
    curl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld

COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

COPY ./conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]

CMD ["mysqld", "--init-file=/etc/mysql/init.sql", "--user=mysql", "--console"]