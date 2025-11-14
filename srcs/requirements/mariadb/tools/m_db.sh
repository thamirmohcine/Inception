#!/bin/bash

# mariadbd  Ver 10.11.14-MariaDB-0+deb12u2 for debian-linux-gnu on x86_64 (Debian 12)
# mariadbd  Ver 10.5.29-MariaDB-0+deb11u1 for debian-linux-gnu on x86_64 (Debian 11)
# HERE IT WILL LISTEN ON LINUX SOCKET 
service mariadb start

sleep 5

# 
mariadb -e "CREATE DATABASE IF NOT EXISTS  $MYSQL_DATABASE;"
mariadb -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%'IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -e "FLUSH PRIVILEGES;"

# HERE WILL SHUT IT DOWN AND RUN IT SAFELY IN A SPECIFIC PORT AND DEFAULT IP
mariadb-admin shutdown
exec mariadbd-safe --bind-address=0.0.0.0