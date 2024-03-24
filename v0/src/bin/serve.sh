#! /bin/sh
rye run python -m gunicorn -k gevent --timeout 3000 -w 1 irchub.wsgi:application