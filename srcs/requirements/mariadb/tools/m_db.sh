#!/bin/bash


# 
service mariadb start
sleep 10

# 
mariadb -e "create database if not exists $MYSQL_DATABASE;"
mariadb -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' identified by '$MYSQL_PASSWORD';"
mariadb -e "FLUSH PRIVILEGES;"

# 
mariadb-admin shutdown
mariadbd-safe --port=3306 --bind-address=0.0.0.0