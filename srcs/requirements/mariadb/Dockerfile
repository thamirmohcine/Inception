FROM debian:bookworm

RUN apt update && apt upgrade -y && apt install mariadb-server -y

COPY ./tools/m_db.sh .

RUN chmod +x ./m_db.sh

ENTRYPOINT ["./m_db.sh"]
