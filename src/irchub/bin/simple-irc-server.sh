#!/usr/bin/env sh
ACTION=$1
[ "${ACTION}x" = "x" ] && ACTION="up"

if [ "$ACTION" = "up" ]; then 
    docker container run --rm --name irchub-ircd -p 127.0.0.1:4440:6667 inspircd/inspircd-docker
fi

if [ "$ACTION" = "down" ]; then
    docker container rm -f irchub-ircd
fi