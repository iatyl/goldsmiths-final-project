import time
import typing as t
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime

from django.utils import timezone
from irc.client import ServerConnection


@dataclass
class IRCConnection:
    _is_pending: bool = False
    connected_at: t.Optional[datetime] = None
    _server_connection: t.Optional[ServerConnection] = None

    @property
    def is_pending(self):
        return self._is_pending

    @is_pending.setter
    def is_pending(self, v):
        if v is False:
            self.connected_at = timezone.now()
        self._is_pending = v

    @property
    def server_connection(self) -> t.Optional[ServerConnection]:
        while self.is_pending:
            time.sleep(0.5)
        return self._server_connection

    @server_connection.setter
    def server_connection(self, s):
        self._server_connection = s


all_connections = defaultdict(IRCConnection)
