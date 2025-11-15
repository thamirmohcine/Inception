FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install php php-mysql curl php-fpm netcat-traditional -y

RUN sed -i 's#listen = /run/php/php8.2-fpm.sock#listen = 0.0.0.0:9000#' /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/w_p.sh .

RUN chmod +x ./w_p.sh

WORKDIR /var/www/html

ENTRYPOINT ["/w_p.sh"]