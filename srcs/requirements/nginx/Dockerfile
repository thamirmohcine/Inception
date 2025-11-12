FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install nginx openssl  -y   

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]