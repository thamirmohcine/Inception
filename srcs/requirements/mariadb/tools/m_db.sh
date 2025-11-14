#!/bin/bash

# mariadbd  Ver 10.11.14-MariaDB-0+deb12u2 for debian-linux-gnu on x86_64 (Debian 12)
# mariadbd  Ver 10.5.29-MariaDB-0+deb11u1 for debian-linux-gnu on x86_64 (Debian 11)
service mariadb start

sleep 5

mariadb -h localhost -e "CREATE DATABASE IF NOT EXISTS  $MYSQL_DATABASE;"
mariadb -h localhost -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -h localhost -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%'IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -h localhost -e "FLUSH PRIVILEGES;"

mariadb-admin shutdown
exec mariadbd-safe --bind-address=0.0.0.0