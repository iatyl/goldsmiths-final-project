#! /bin/sh
rye run python manage.py migrate
rye run python manage.py collectstatic --noinput