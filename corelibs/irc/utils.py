import ssl

from irc.connection import Factory as IRCConnectionFactory


def ssl_factory() -> IRCConnectionFactory:
    return IRCConnectionFactory(wrapper=ssl.wrap_socket)
