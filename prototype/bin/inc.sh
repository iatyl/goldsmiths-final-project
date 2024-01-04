#!/usr/bin/env sh
install_dependencies() {
    if hash pip-compile >/dev/null 2>&1; then
      pip-compile requirements/$1.in -o requirements.txt && pip-sync
    else
      printf "pip-compile executable was not found"
    fi
}
