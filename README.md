#  LAMJ stack container

**L**inux, **A**pache, **M**ySql **J**ava

LAMK image used for hosting LAMJ stack application

Can also be used to build with Maven. 

### Details

### Linux
The docker container is `FROM tomcat:11.0-jdk17` an official image maintained by the Docker Commununity. See the [Tomcat 11 dockerfile](https://github.com/docker-library/tomcat/blob/f413ee3c1b5be50b58db8cd1e9caff62a040b868/11.0/jdk17/temurin-jammy/Dockerfile)) which itself is `FROM eclipse-temurin:17-jdk-jammy` an official image maintained by the Eclipse Temuring projects (see [the JDK 17 dockerfile](https://github.com/adoptium/containers/blob/d3c9617e83eb706aff74c095fd531fe31e359674/17/jdk/ubuntu/jammy/Dockerfile.releases.full)).

Run it like this:

``` shell
docker run -it  --rm  --pid=host -v $(pwd):/app:rw --workdir /app lakruzz/lamj /bin/bash
```

See it on Docker Hub [lakruzz/lamj](https://hub.docker.com/repository/docker/lakruzz/lamj)
