import typing as t

from django.contrib.auth import get_user_model
from django.db import models
from irc.client import Reactor, ServerConnection

from corelibs.irc.store import all_connections
from corelibs.irc.utils import ssl_factory

UserModel = get_user_model()


class IRCClient(models.Model):
    user = models.ForeignKey(UserModel, on_delete=models.CASCADE, null=True)
    server = models.CharField(max_length=255)
    is_ssl = models.BooleanField(default=True)
    port = models.IntegerField(default=6697)
    nick = models.CharField(max_length=100)
    real_name = models.CharField(max_length=100)
    sasl_login = models.CharField(max_length=125)
    sasl_passwd = models.CharField(max_length=125)
    _join_list = models.JSONField(default=list)

    @property
    def join_list(self):
        if isinstance(self._join_list, t.Sequence) is False:
            self._join_list = []
            self.refresh_from_db()
        return self._join_list

    def get_connection(self) -> ServerConnection:
        if all_connections[self.pk] is not None:
            return all_connections[self.pk]
        extra = {}
        if self.is_ssl:
            extra["connect_factory"] = ssl_factory()
        reactor = Reactor()
        conn = reactor.server().connect(self.server, self.port, self.nick, **extra)
        for channel in self.join_list:
            conn.join(channel)
        all_connections[self.pk] = conn
        return all_connections[self.pk]
