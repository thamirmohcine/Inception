FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install php php-mysql curl php-fpm netcat-traditional -y

COPY ./tools/w_p.sh .

RUN chmod +x ./w_p.sh

ENTRYPOINT ["./w_p.sh"]