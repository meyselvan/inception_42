FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	php7.4-fpm \
	php7.4-mysql \
	php7.4-cli \
	php7.4-curl \
    curl \
    ca-certificates \
    mariadb-client \
    netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html
RUN mkdir -p /run/php
RUN chown -R www-data:www-data /run/php

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

CMD ["php-fpm7.4", "-F"]