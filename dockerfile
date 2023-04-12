FROM tomcat:11.0-jdk17
# FROM eclipse-temurin:20-jre-jammy

ARG PSCALE_VERSION=0.136.0
ARG PSCALE_ARCH=amd64 

LABEL author="Lakruzz <lars@lakruzz.com>"
LABEL maintainer="Lakruzz <lars@lakruzz.com>"

# This is the default password for the root user
ENV MYSQL_ROOT_PASSWORD=root 

RUN apt-get update && apt upgrade -y

RUN apt-get install -y \
    mysql-server \
    mysql-client 

RUN apt-get install -y \
    maven \
    gradle

RUN apt-get install -y \
    git \
    gh \
    nano

RUN curl -sSfL https://github.com/planetscale/cli/releases/download/v${PSCALE_VERSION}/pscale_${PSCALE_VERSION}_linux_${PSCALE_ARCH}.deb -O
RUN dpkg -i pscale_${PSCALE_VERSION}_linux_${PSCALE_ARCH}.deb
RUN rm pscale_${PSCALE_VERSION}_linux_${PSCALE_ARCH}.deb

RUN mkdir -p /var/lib/mysql && \
    usermod -d /var/lib/mysql/ mysql
RUN useradd --no-log-init -r -g staff vscode

RUN cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/installationde-faults.mysqld.cnf
COPY mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN mkdir /docker-entrypoint-initdb.d || true

COPY lamj.init.sh /usr/local/bin


WORKDIR /app
EXPOSE 8080 3306

CMD lamj.init.sh && \
    tail -f /dev/null
 
