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
### Install Dependencies
Install `pip-tools`:
```shell
pip3 install pip-tools
```
Install dependencies:
```shell
/usr/bin/sh ./bin/devdeps.sh
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