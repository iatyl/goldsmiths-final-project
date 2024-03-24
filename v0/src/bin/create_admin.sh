#!/bin/sh
echo "creating admin(superuser) named 'root', please provide its password"
rye run python ./manage.py createsuperuser --username root --email ''