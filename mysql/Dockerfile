FROM mysql:latest

ARG MYSQL_USER
ARG MYSQL_PASSWORD

ENV MYSQL_RANDOM_ROOT_PASSWORD=yes \
    MYSQL_DATABASE=gophish \
    MYSQL_USER=${MYSQL_USER} \
    MYSQL_PASSWORD=${MYSQL_PASSWORD}


COPY ./my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 644 /etc/mysql/conf.d/my.cnf

ADD ./init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 3306