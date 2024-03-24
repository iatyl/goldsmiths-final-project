import threading
import time
import typing as t
from dataclasses import dataclass
from datetime import datetime

from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.db import models
from django.utils import timezone
from irc import events
from irc.client import Event, Reactor, ServerConnection

from corelibs.irc.store import all_connections
from corelibs.irc.utils import generate_event_handler, ssl_factory

UserModel = get_user_model()


class IRCClient(models.Model):
    user = models.ForeignKey(UserModel, on_delete=models.CASCADE, null=True)
    name = models.CharField(max_length=500, null=True, blank=True)
    server = models.CharField(max_length=255)
    is_ssl = models.BooleanField(default=True)
    port = models.IntegerField(default=6697)
    nick = models.CharField(max_length=100)
    real_name = models.CharField(max_length=100)
    sasl_login = models.CharField(max_length=125, null=True, blank=True)
    sasl_passwd = models.CharField(max_length=125, null=True, blank=True)
    is_enabled = models.BooleanField(default=True)
    _join_list = models.JSONField(default=list)

    def channel_members(self, channel: str) -> t.List[str]:
        cache_key = f"client-pk-{self.pk}-{channel}"
        if channel not in self.join_list:
            return []
        cached_result = cache.get(cache_key)
        if cached_result:
            return cached_result
        try:
            self.command(f"NAMES {channel}")
        except:
            pass
        time.sleep(0.5)
        name_replies = (
            IRCEvent.objects.filter(client=self)
            .filter(event_type="namreply")
            .order_by("-inserted_at")
            .all()
        )
        for reply in name_replies:
            if len(reply.event_arguments) != 3 or reply.event_arguments[1] != channel:
                continue
            people = reply.event_arguments[2].split()
            cache.set(cache_key, people, 100)
            return people
        return []

    def command(self, raw_command: str):
        connection = self.get_connection()
        if connection is None:
            raise ValueError("could not get connection")
        connection.send_raw(raw_command)

    @property
    def client_name(self) -> str:
        return self.name or self.server

    def serialize(self):
        return {
            "pk": self.pk,
            "name": self.name,
            "server": self.server,
            "port": str(self.port),
            "nick": self.nick,
            "real_name": self.real_name,
            "join_list": self.join_list,
            "connected_at": self.connected_at.timestamp()
            if self.connected_at
            else None,
        }

    @property
    def join_list(self):
        if isinstance(self._join_list, t.Sequence) is False:
            self._join_list = []
            self.refresh_from_db()
        return self._join_list

    @property
    def connected_at(self) -> t.Optional[datetime]:
        self.get_connection()
        return all_connections[self.pk].connected_at

    def get_connection(self, reset=False) -> t.Optional[ServerConnection]:
        if reset:
            del all_connections[self.pk]
        if all_connections[self.pk].server_connection is not None:
            return all_connections[self.pk].server_connection
        all_connections[self.pk].is_pending = True
        extra = {}
        if self.is_ssl:
            extra["connect_factory"] = ssl_factory()
        reactor = Reactor()
        conn = reactor.server().connect(
            self.server,
            self.port,
            self.nick,
            ircname=self.real_name,
            **extra,
        )

        def join_channels(connection, _):
            for channel in self.join_list:
                connection.join(channel)

        conn.add_global_handler("welcome", join_channels)
        handler = generate_event_handler(self.pk, IRCEvent.handle_for_client)
        for event in events.all:
            conn.add_global_handler(event, handler)
        threading.Thread(target=reactor.process_forever).start()
        all_connections[self.pk].server_connection = conn
        all_connections[self.pk].is_pending = False
        return all_connections[self.pk].server_connection


class IRCEvent(models.Model):
    client = models.ForeignKey(
        IRCClient, null=True, blank=True, on_delete=models.CASCADE
    )
    event_type = models.CharField(max_length=100)
    event_source = models.CharField(max_length=200, null=True, blank=True)
    event_target = models.CharField(max_length=200, null=True, blank=True)
    event_arguments = models.JSONField(default=list)
    inserted_at = models.DateTimeField(default=timezone.now)

    def serialize(self):
        if self.event_type == "pubmsg":
            source_nick, source_name = self.event_source.split("!", 1)
            return {
                "timestamp": str(self.inserted_at.timestamp()),
                "nick": source_nick,
                "name": source_name,
                "channel": self.event_target,
                "message": self.event_arguments[0]
                if len(self.event_arguments) > 0
                else "",
            }
        raise NotImplementedError("Work in progress..")

    @classmethod
    def from_event_object(cls, client, obj: Event):
        return cls(
            client=client,
            event_type=obj.type,
            event_source=obj.source,
            event_target=obj.target,
            event_arguments=obj.arguments,
        )

    @classmethod
    def handle_for_client(cls, client_pk, connection, event):
        client = IRCClient.objects.get(pk=client_pk)
        irc_event = cls.from_event_object(client, event)
        irc_event.save()


@dataclass
class ChannelInfo:
    members: t.Optional[t.List[str]] = None
    error: t.Optional[str] = None

    def __post_init__(self):
        if self.members is None:
            self.members = []
