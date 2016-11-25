# usage: see ./build
FROM alpine:edge

MAINTAINER Coder Of Salvation <info@leon.vankammen.eu>

ENV VERSION=v4.1.1

ADD install /install
ADD opt /opt
RUN apk add --update bash curl openssh ca-certificates && bash /install/install

#VOLUME .ssh.etc /etc/ssh
#VOLUME  srv /srv
#VOLUME .ssh /home/nodejs/.ssh
#VOLUME .podrc /home/nodejs/.podrc

EXPOSE 22 80 19999 3000 3001

CMD [ "sh","-c","apk update; ROOTPASSWD=$ROOTPASSWD PASSWD=$PASSWD HOSTNAME=$HOSTNAME /install/boot ; su -c 'pm startall' nodejs; cat" ]
