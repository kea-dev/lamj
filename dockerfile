FROM tomcat:11.0-jdk17

LABEL author="Lakruzz <lars@lakruzz.com>"
LABEL maintainer="Lakruzz <lars@lakruzz.com>"

WORKDIR /app
EXPOSE 8080 3306 3307

RUN apt-get update && apt upgrade -y

RUN apt-get install -y \
    mysql-server \
    mysql-client 

RUN apt-get install -y \
    maven \
    gradle

RUN apt-get install -y \
    git \
    gh

RUN export PSCALE_VERSION=0.133.0 && \
    curl -sSfL https://github.com/planetscale/cli/releases/download/v${PSCALE_VERSION}/pscale_${PSCALE_VERSION}_linux_amd64.deb -O && \
    dpkg -i pscale_${PSCALE_VERSION}_linux_amd64.deb && \
    rm pscale_${PSCALE_VERSION}_linux_amd64.deb
