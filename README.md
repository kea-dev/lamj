#  LAMJ stack container

**L**inux, **A**pache, **M**ySql **J**ava

LAMJ image used for hosting LAMJ stack application

Can also be used during development to build with Maven or gradle. 

## Details

See source on GitHub: [kea-dev/lamj](https://github.com/kea-dev/lamj)

### Linux
The docker container is `FROM tomcat:11.0-jdk17` an [official Tomcat image](https://hub.docker.com/_/tomcat) maintained by the Docker Commununity. See the [Tomcat 11 dockerfile](https://github.com/docker-library/tomcat/blob/f413ee3c1b5be50b58db8cd1e9caff62a040b868/11.0/jdk17/temurin-jammy/Dockerfile)) which itself is `FROM eclipse-temurin:17-jdk-jammy` an official [Eclipse Temurin image](https://hub.docker.com/_/eclipse-temurin) maintained by the Eclipse Temurin project (see [the JDK 17 dockerfile](https://github.com/adoptium/containers/blob/d3c9617e83eb706aff74c095fd531fe31e359674/17/jdk/ubuntu/jammy/Dockerfile.releases.full)). Which itself is `FROM ubuntu:22.04` a.k.a _Jammy_.

### Apache
This image includes Tomcat.

The image it inherits from includes the CMD:

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

`tail -f /dev/null` is required if you don't use this image for anything other than mysql. But if you start `catalina.sh` or run `java -jar ...` then you don't need it.

You can see [lamj.init.sh](https://github.com/kea-dev/lamj/blob/main/lamj.init.sh). 

- It creates and grants permissions to a user `'root'@'%'`  which is used when accessing the service from an IP address (as opposed to the logical name `localhost`). 
- It sets the password for both users `'root'@'%'` and `'root'@'localhost'`
- It looks for `*.sql` files in the directory `/docker-entrypoint-initdb.d` and if it finds any it executes them in alphabetically order against the service. This mimics the behavior of the official `mysql` image.

### Java
This image installs OpenJDK, Maven and Gradle

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
  lakruzz/lamj:arm64 \
  /usr/bin/env bash
```

**Note on Windows:**</br>
The `-v` switch is tricky on windows you can use Command line terminal - but _not_ PowerShell -and you must swap the `-v` switch to:

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

You simply just ditch the last line - the container will then default run the `lamj.init.sh` script - and start the database service and set the root paasword.

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
  lakruzz/lamj:arm64
```

### To use it as off-set for your own LAMJ app - in a self-hosted container
For serious production sites you'll probably want to separate your app and your database into an app server and a managed database service.

This could be two different containers: the app coming from [Eclipse Temurin image](https://hub.docker.com/_/eclipse-temurin) and the database coming from [mysql](https://hub.docker.com/_/mysql). Or the database could bo on a managed as a service - like PlanetScale.

But this neat image allows you to do the following (springboot example):

In your project:
1. Configure your (springboot) project to build a _fat_ `*.jar``
2. Put all the scripts you want to initialize  your database with in separate folder. Name them so the order to run them is alphabetical
3. Create a docker file
   ```dockerfile
   FROM lakruzz/lamj:latest
   
   RUN mkdir /app || true
   COPY target/*.jar /app
   
   COPY src/mysql/init/* /docker-entrypoint-initdb.d
   
   CMD set -eux; \
       lamj.init.sh; \
       java -jar /app/*.jar;
   ```
4. Build your docker file
   ```shell
   docker build -t myapp .
   ```
5. Run your app
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


The container built this way is a single container (no docker compose needed) and can be hosted as a single instance _anywhere_:

- [Top 10 Docker Hosting Platforms](https://blog.back4app.com/docker-hosting-platforms/)
- [Best Docker Cloud Hosting](https://webhostingadvices.com/best-docker-cloud-hosting/)
- [8 Best Docker Hosting Platforms for your Containers](https://geekflare.com/docker-hosting-platforms/)
- [Best Docker Hosting Platforms of 2023](https://digital.com/best-web-hosting/docker/)

## Example:

Have a look at this sample project [lakruzz/SuperheltV5](https://github.com/lakruzz/SuperheltV5).
