FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# System update + gerekli araçlar + PHP 7.4 için sury.org deposu
RUN apt-get update && apt-get install -y \
    lsb-release apt-transport-https ca-certificates curl gnupg2 wget

# PHP 7.4 deposunu ekle
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg

# PHP ve diğer gerekli paketleri kur
RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    mariadb-client \
    netcat-openbsd \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# WP CLI kurulumu
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# WordPress ana dizinini oluştur
RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php

# PHP-FPM ayarlarını kopyala
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# WordPress yapılandırma dosyasını kopyala
COPY ./conf/wp-config.php /var/www/html/wp-config.php
RUN chown www-data:www-data /var/www/html/wp-config.php && chmod 640 /var/www/html/wp-config.php

# Setup script
COPY ./tools/wordpress_setup.sh /usr/local/bin/wordpress_setup.sh
RUN chmod +x /usr/local/bin/wordpress_setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]
CMD ["php-fpm7.4", "-F"]
