FROM mysql:latest

ENV MYSQL_DATABASE route-control
ENV MYSQL_ROOT_PASSWORD test
ENV MYSQL_USER test
ENV MYSQL_PASSWORD test

COPY ./route-control.cnf /etc/mysql/conf.d
COPY ./init.sql /docker-entrypoint-initdb.d/