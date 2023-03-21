FROM tomcat:11.0-jdk17

RUN apt-get update && apt upgrade -y

RUN apt-get install -y \
    mysql-server \
    mysql-client \
    maven

COPY pscale_0.131.0_linux_amd64.deb /tmp/pscale_0.131.0_linux_amd64.deb

RUN dpkg -i /tmp/pscale_0.131.0_linux_amd64.deb && rm /tmp/pscale_0.131.0_linux_amd64.deb




