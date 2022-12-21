FROM tomcat:11.0-jdk17

RUN apt-get update && apt upgrade -y

RUN apt-get install -y \
    mysql-server \
    maven




