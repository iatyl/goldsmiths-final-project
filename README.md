# IRCHub (Final Year Project for BSc Computer Science)
IRCHub is a modern IRC(Internet Relay Chat) client service for sane people.

It's not great for now, but it will be good later.

A rewrite in [Phoenix](https://www.phoenixframework.org/) will probably happen around Christmas to address several performance issues.

# Prototype Demo
A working instance is deployed on [Hetzner](https://www.hetzner.com/): [https://fyp.gscoursework.thealois.com](https://fyp.gscoursework.thealois.com)
## Credentials
* username: `password`
* password: `Goldsmiths`
## Screenshots
![](https://gitlab.doc.gold.ac.uk/zwang038/irchub/-/raw/main/screenshots/4.png)
# how to run (on linux or macos)
## python version
3.10.13 is mandatory.

You could use [`asdf-vm`](https://asdf-vm.com/), [`rtx`](https://github.com/jdx/rtx) or [`pyenv`](https://github.com/pyenv/pyenv) to manage python versions
## what's next
### Virtual Environment
make a virtualenv:
```shell
python3 -m venv .venv
```
activate the virtualenv:
```shell
. .venv/bin/activate
```
### Install Dependencies
Install `pip-tools`:
```shell
pip3 install pip-tools
```
Install dependencies:
```shell
/usr/bin/sh ./bin/devdeps.sh
```
### Setup Environment Variables
run `cp .env.sample .env`, and edit `.env`.

If you would like to use sqlite3 instead of mysql, please delete `DEV_DATABASE_URL` and `DATABASE_URL`. The sqlite3 database will be setup at the project's root directory, called `db.sqlite3`
### Migrate DB
```shell
python3 ./manage.py migrate
```
### Collect Static Files
```
python3 ./manage.py collectstatic
```
### Create a user
```
python3 ./manage.py createsuperuser
```

### Ready. Set. Run!
> Note that async IO and multiprocessing are not supported for now.
> and multiprocessing is planned.
```shell
# use precisely one gevent worker
gunicorn -k gevent -w 1 irchub.wsgi:application
```
### Access the web page.
Just go to `http://127.0.0.1:8000`.

And for user management, please go to `http://127.0.0.1:8000/not-admin/`. (http://127.0.0.1:8000/admin/ is a honeypot)

> Sapere aude.
