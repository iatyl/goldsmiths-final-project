import ssl

from irc.connection import Factory as IRCConnectionFactory

from corelibs.irc.store import all_connections


def ssl_factory() -> IRCConnectionFactory:
    return IRCConnectionFactory(wrapper=ssl.wrap_socket)


def generate_event_handler(client_pk, handler):
    def on_event(
        connection,
        event,
    ):
        handler(client_pk, connection, event)

    return on_event
