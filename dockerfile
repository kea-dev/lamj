FROM eclipse-temurin:20-jre-jammy

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

RUN export PSCALE_VERSION=0.136.0 && \
   curl -sSfL https://github.com/planetscale/cli/releases/download/v${PSCALE_VERSION}/pscale_${PSCALE_VERSION}_linux_amd64.deb -O && \
   dpkg -i pscale_${PSCALE_VERSION}_linux_amd64.deb && \
   rm pscale_${PSCALE_VERSION}_linux_amd64.deb

RUN mkdir -p /var/lib/mysql && \
    usermod -d /var/lib/mysql/ mysql
RUN useradd --no-log-init -r -g staff vscode

COPY mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN mkdir /docker-entrypoint-initdb.d || true

RUN mkdir /lamj || true
COPY lamj.init.sh /lamj/

WORKDIR /app
EXPOSE 8080 3306

CMD /lamj/lamj.init.sh && \
    tail -f /dev/null
 
