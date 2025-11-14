#!/bin/bash

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /bin/wp

cd /var/www/html

wp core download --allow-root
wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=$MYSQL_HOST --allow-root

wp core install  --url="$DOMAIN_NAME" --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root
wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD  --role=$WP_USER_ROLE --allow-root

chown -R www-data:www-data .
chmod -R 775 .


sed -i 's#listen = /run/php/php8.2-fpm.sock#listen = 0.0.0.0:9000#' /etc/php/8.2/fpm/pool.d/www.conf
exec php-fpm8.2 -F
