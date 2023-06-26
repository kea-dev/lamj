---
layout: post
title:  "LAMJ Docker Image"
date:   2023-06-26 09:18:14 +0000
categories: Docker Java MySql
---
#  LAMJ stack container

**L**inux, **A**pache, **M**ySql **J**ava

LAMJ image used for hosting LAMJ stack application

Can also be used during development to build with Maven or gradle. 

## Details

See source on GitHub: [kea-dev/lamj](https://github.com/kea-dev/lamj)

### Linux
The docker container is 
- `FROM tomcat:11.0-jdk17` an [official Tomcat image](https://hub.docker.com/_/tomcat) maintained by the Docker Commununity. See the [Tomcat 11 dockerfile](https://github.com/docker-library/tomcat/blob/f413ee3c1b5be50b58db8cd1e9caff62a040b868/11.0/jdk17/temurin-jammy/Dockerfile)). This image is;
- `FROM eclipse-temurin:17-jdk-jammy` an official [Eclipse Temurin image](https://hub.docker.com/_/eclipse-temurin) maintained by the Eclipse Temurin project (see [the 17-jdk-jammy dockerfile](https://github.com/adoptium/containers/blob/d3c9617e83eb706aff74c095fd531fe31e359674/17/jdk/ubuntu/jammy/Dockerfile.releases.full)). And this  itself is;
- `FROM ubuntu:22.04` a.k.a _Jammy_.

### Apache (Tomcat)
This image includes Tomcat.

The image it inherits from includes the `CMD`:

```dockerfile
CMD ["catalina.sh", "run"]
```

If you use this image to host a springboot app it's typically complied as a _fat_ `.jar` which contains the Tomcat server itself and you won't have to start Tomcat. But if your project is a `.war` than you might want to add the `CMD` above to your own container too.

### MySql
This image installs, configures and starts a mysql server. 

#### Alternative image: mysql:8.0
If Mysql is _the only thing_ you really need - It's possibly that you just want to use the community maintained image: [mysql](https://hub.docker.com/_/mysql) it's more battle proof and the shell script [docker-entrypoint.sh](https://github.com/docker-library/mysql/blob/master/8.0/docker-entrypoint.sh) it starts is far more advanced than the one used in this image.

#### This image
...on the other hand - is a show case in the minimum settings and steps that are needed in order  to install and configure mysql ([mysqld.cnf](https://github.com/kea-dev/lamj/blob/main/mysqld.cnf)) - I've marked the changes made in this image with `LAMJ` in the comments. The original `*.cnf` is backed up on the image: `/etc/mysql/mysql.conf.d/installation-deaults.mysqld.cnf`. 

The image uses `CMD`to run:

```dockerfile
CMD lamj.init.sh && \
    tail -f /dev/null
```

`tail -f /dev/null` keeps the container alive after af the databas service is started. It's only required if you don't use this image for anything other than mysql. But if you start `catalina.sh` or run `java -jar ...` then you don't need it.

You can see [lamj.init.sh](https://github.com/kea-dev/lamj/blob/main/lamj.init.sh). 

- It creates and grants permissions to a user `'root'@'%'`  which is used when accessing the service from an IP address (as opposed to the logical name `localhost`). 
- It sets the password for both users `'root'@'%'` and `'root'@'localhost'`
- It looks for `*.sql` files in the directory `/docker-entrypoint-initdb.d` and if it finds any it executes them in alphabetically order against the service. This mimics the behavior of the official `mysql` image.

### Java
This image installs OpenJDK, Maven and Gradle

### Utilities

The image also installs:

- git
- GitHub CLI
- Pscale CLI

## Run

Run it like this:

The image is maintained in three tags

- `amd64` same as `latest`
- `arm64`

On Mac with M1 or M2 Processors use `arm64`. In most other contexts go with `amd64` or `latest`. If you don't specify anything you'll get `latest`.

### To run a bash shell - or any supported CLI - with your current working directory mapped in as `/app` 
``` shell
docker run \            
  -it  \
  --rm  \
  -p 8080:8080 \
  -p 3306:3306 \
  --pid=host \
  -v $(pwd):/app:rw --workdir /app \
  lakruzz/lamj:latest \
  /usr/bin/env bash
```

**Note on Windows:**</br>
The `-v` switch is tricky on windows you can use the command line terminal `cmd` - but _not_ PowerShell. And you must swap the `-v` switch to:

```shell
-v %cd%://app:rw --workdir //app
```

You can replace `bash` with a valid command to use any of the CLIs the image offers:

- `gh`
- `mvn`
- `gradle`
- `mysql`
- `pscale`

See it on Docker Hub [lakruzz/lamj](https://hub.docker.com/repository/docker/lakruzz/lamj)

### To run a mysql server

You simply just ditch the last line - the container will then default run the `lamj.init.sh` script - and start the database service and set the root password.

Note: If you don't specify a password it will default to "root".

```shell
docker run \            
  -it  \
  --rm  \
  -p 8080:8080 \
  -p 3306:3306 \
  --pid=host \
  -v $(pwd):/app:rw --workdir /app \
  -e MYSQL_ROOT_PASSWORD=mysecretpassword
  lakruzz/lamj:latest
```

### To use it as off-set for your own LAMJ app - in a self-hosted container
For serious production sites you'll probably want to separate your app into two different deploys. But this neat image allows you to optimize the development process and even host your app in a single docker container (no need for docker compose) 

#### springboot+mysql example):

In your project:
1. Configure your (springboot) project to build a _fat_ `*.jar` - as opposed to a `.war`
2. Put all the scripts you want to initialize your database with in separate folder. Name them so the order to run them is alphabetical. In the example below I have my sql files in `src/mysql/init/`
3. Create a docker file
   ```dockerfile
   FROM lakruzz/lamj:latest
 
   COPY src /src
   COPY pom.xml /pom.xml
   RUN set -ex; \
        mvn -f /pom.xml clean package; \
        mv /target/*.jar /app/; \
        rm -rf /target; \
        rm -rf /src; \
        rm -rf /pom.xml;
   
   COPY src/mysql/init/* /docker-entrypoint-initdb.d
   
   CMD set -ex; \
       lamj.init.sh; \
       java -jar /app/*.jar;
   ```
4. Build your docker file like this:
   ```shell
   docker build -t myapp .
   ```
5. Run your app like this:
   ```shell
   docker run \
     -it \
     --rm \
     --name myapp \
     --pid=host \
     -p 8080:8080 \
     -p 3306:3306 \
     -e MYSQL_ROOT_PASSWORD=mysecretpassword \
     myapp
     ```

The container built this way is a single container (no docker compose needed) and can be hosted as a single instance _anywhere_:

- [Top 10 Docker Hosting Platforms](https://blog.back4app.com/docker-hosting-platforms/)
- [Best Docker Cloud Hosting](https://webhostingadvices.com/best-docker-cloud-hosting/)
- [8 Best Docker Hosting Platforms for your Containers](https://geekflare.com/docker-hosting-platforms/)
- [Best Docker Hosting Platforms of 2023](https://digital.com/best-web-hosting/docker/)

#### A note on `application.properties`
If your jdbc is using `localhost` the database is accessed through a socket and the IP address 3306 does _not_ need to be exposed. The authenticated user is `'root'@'localhost'`.

```ini
# application.properties
# database info
spring.datasource.url=jdbc:mysql://localhost:3306/superhero
spring.datasource.username=root
spring.datasource.password=root
```
If your jdbc is using `127.0.0.1` which from a network perspective is also _localhost_ but in MySql makes quite a difference. The database is _not_ accessed through a socket, but actually uses the WAN side IP address on tcp port 3306. For this to work the port _must_ be be exposed. The authenticated user is `'root'@'%'`.

```ini
# application.properties
# database info
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/superhero
spring.datasource.username=root
spring.datasource.password=root
```
If 

## Example:

Have a look at this sample project [lakruzz/SuperheltV5](https://github.com/lakruzz/SuperheltV5).

Read the `CONTRIBUTE.md` file for details.

**Summary:**<br/>

It's has three different application properties:

- `application-dev.properties`
- `application-prod.properties`
- `application.properties`

Profiles for `dev` and `prod` are defined in the `pom.xml`

And can be specified during build and execution:

#### Builds:
```shell
# uses application.properties a.k.a "default"
mvn clean package 

# uses application-dev.properties
mvn -Dspring.profiles.active=dev clean package 

# uses application-prod.properties
mvn -Dspring.profiles.active=prod clean package 
```

#### Runs:
```shell
# If application is built with application.properties
java -jar target/*.jar

# If application is built with application-dev.properties
java -Dspring.profiles.active=dev -jar target/*.jar

# If application is built with application-prod.properties
java -Dspring.profiles.active=prod -jar target/*.jar
```

...Happy hacking!
