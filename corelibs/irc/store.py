import time
import typing as t
from collections import defaultdict
from dataclasses import dataclass

from irc.client import ServerConnection


@dataclass
class IRCConnection:
    is_pending: bool = False
    _server_connection: t.Optional[ServerConnection] = None

    @property
    def server_connection(self) -> t.Optional[ServerConnection]:
        while self.is_pending:
            time.sleep(0.5)
        return self._server_connection

    @server_connection.setter
    def server_connection(self, s):
        self._server_connection = s


all_connections = defaultdict(IRCConnection)
