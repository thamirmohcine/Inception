FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install nginx openssl  -y   

RUN mkdir /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 180 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server_ca.key -out /etc/nginx/ssl/server_ca.crt \
    -subj "/C=MA/ST=Khnifra-beniMellal/L=Khouribga/O=1337/OU=IT/CN=mthamir.42.fr"


COPY ./conf/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]