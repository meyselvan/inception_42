FROM debian:bullseye

# Paket güncellemesi ve gerekli paketlerin kurulumu
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# WordPress CLI kurulumu
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM konfigürasyonu
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf

# WordPress dizini oluştur
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# WordPress kurulum scripti
COPY tools/wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

EXPOSE 9000

CMD ["/usr/local/bin/wordpress_setup.sh"]
