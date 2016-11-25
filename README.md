# Nodejs + pm.sh microservices docker

Simple to-go nodejs docker:

* alpine linux (~32mb linux distro)
* pm.sh nodejs processmanager (+github/bitbucket webhooks)
* http proxy `srv/apps/proxytable.js`

## Usage: simple 

look at [build](build) 

    $ BUILD=1 RUN=1 ./build
    + docker build -t nodejs-pm.sh .
    + docker run -it --volume=/home/username/docker.nodejs.pod/srv:/srv --volume=/home/username/docker.nodejs.pod/.ssh:/home/nodejs/.ssh --volume=/home/username/docker.nodejs.pod/.podrc:/home/nodejs/.podrc --volume=/home/username/docker.nodejs.pod/.ssh.etc:/etc/ssh --env=ROOTPASSWD=test --env=PASSWD=test --env=HOSTNAME=nodepod -p 23:22 -p 8081:8081 -p 8080:8080 --name=nodejs-pm.sh nodejs-pm.sh

This will build and run a docker which has pod & ssh pre-installed.
    
    $ RUN=1 BUILD=1 LOGIN=1 PROXY_PORT=8080 WEBHOOK_PORT=8081 ./build 

to install global npm_modules:

    $ NPM_MODULES="typescript coffeescript" BUILD=1 LOGIN=1 ./build

    $ PROXY_PORT=8080 WEBHOOK_PORT=8081 BUILD=1 RUN=1 LOGIN=1 ./build 


                         ..........  bb/github   gitrepo       
                         :            webhook     push                  
                         :              :          :                      
                    +--------------------------------------------------------------------+
                    |                          PM.sh (port 8081)                         |       
                    +--------------------------------------------------------------------+
                         :              :          :         
                         :              :          :  
                    +--------+      +----------------+       
     port 8080  ->  | proxy  |---+--+ microservice A +     
                    +--------+   |  +----------------+       
                                 |      :          :  
                                 |  +----------------+
                                 +--+ microservice B +
                                    +----------------+

> NOTE: the lightweight proxy is only installed when `PROXY_PORT=1` is passed

# Usage 

A bit of bash tells a thousands words:

    $ NPM_MODULES="coffeescript purescript" BUILD=1 ./build
    $ docker run                                                 \
      --volume=$(pwd)/srv:/srv                                   \
      --volume=$(pwd)/install:/install                           \
      --volume=$(pwd)/.ssh:/home/nodejs/.ssh                     \
      --volume=$(pwd)/.ssh.etc:/etc/ssh                          \
      --env=PROXY_PORT=80                                        \
      --env=WEBHOOK_PORT=80                                      \
      --env=HOSTNAME=pmnodejs                                    \
      -p 23:22                                                   \
      -p 80:80                                                   \
      -p 8080:8080                                               \
      --name=nodejs-pm.sh                                        \

    $ ssh -p 23 nodejs@localhost pm status
    Password: test
    APP                  STATUS   PORT   RESTARTS   USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND

    proxy                running  80     0          nodejs    1245 1.0  3000      0     0 pts/1       0 -       -    npm start          
    pmserver             stopped  8080   0          

## creating & deploying a new nodejs app

You can create repos locally:

    $ docker exec nodejs-pm.sh /bin/bash 
    bash # su nodejs 
    bash $ cd /srv/apps
    bash $ git clone http://github.com/yourusername/myapp.git /srv/apps/myapp
    bash $ pm add /srv/apps/myapp
    bash $ pm start myapp --log
    ( see stdout/stderror )
    
Now in github/bitbucket specify this webhook for pull-events:

* http://yourdomain.com:8080/pull/myapp

Now a `git push` to github will: 

* let github call pm.sh using the url above 
* pm.sh will do `pm stop myapp`
* pm.sh will do `git pull` on myapp 
* pm.sh will do `pm start myapp` 

> Make sure your `~/.ssh/id_rsa.pub` is set as deploymentkey in the repo

## http proxy

The [proxy](https://npmjs.org/package/http-proxy-rules) runs on port 8080.
You can edit `srv/apps/proxytable.js` to update routes.

## Extend boot/install

Just put additional requirements in `install/custom` with few lines of bash:

    apk add mongodb

