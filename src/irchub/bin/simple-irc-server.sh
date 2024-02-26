#!/usr/bin/env sh
hash pipenv >/dev/null 2>&1 || {
    echo "pipenv is not available in path"
    exit
}
PORT=$1
[ "${PORT}x" = "x" ] && PORT=4440
pipenv install irc --skip-lock --ignore-pipfile -q 2>/dev/null
pipenv run python -m irc.server -a 127.0.0.1 -p $PORT