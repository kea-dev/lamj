# lakruzz/lamj

Linux, Apache tomcat, MySql Java

LAMK image used for hosting LAMJ stack application

Can also be used to build with Maven. 

Run it like this:

``` shell
docker run -it  --rm  --pid=host -v $(pwd):/app:rw --workdir /app lakruzz/lamj /bin/bash
```

See it on Docker Hub [lakruzz/lamj](https://hub.docker.com/repository/docker/lakruzz/lamj)