#!/usr/bin/env python
# Example program using irc.client for SSL connections.
#
# This program is free without restrictions; do anything you like with
# it.
#
# Jason R. Coombs <jaraco@jaraco.com>

import itertools
import ssl
import sys

import irc.client

target = "#thelounge"


def on_connect(connection, event):
    if irc.client.is_channel(target):
        connection.join(target)
        return
    main_loop(connection)


def on_join(connection, event):
    main_loop(connection)


def get_lines():
    while True:
        yield sys.stdin.readline().strip()


def main_loop(connection):
    for line in itertools.takewhile(bool, get_lines()):
        print(line)
        connection.privmsg(target, line)
    connection.quit("Using irc.store.py")


def on_disconnect(connection, event):
    raise SystemExit()


def main():
    global target
    port = 6667

    ssl_factory = irc.connection.Factory(wrapper=ssl.wrap_socket)
    kwargs = {}
    if port == 6697:
        kwargs["connect_factory"] = ssl_factory
    reactor = irc.client.Reactor()
    try:
        c = reactor.server().connect("127.0.0.1", port, "bot", **kwargs)
    except irc.client.ServerConnectionError:
        print(sys.exc_info()[1])
        raise SystemExit(1)

    c.add_global_handler("welcome", on_connect)
    c.add_global_handler("join", on_join)
    c.add_global_handler("disconnect", on_disconnect)

    reactor.process_forever()


if __name__ == "__main__":
    main()
