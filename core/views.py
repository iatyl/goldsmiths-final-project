from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import IRCClient
from corelibs.irc.store import all_connections


class ConnectedClientsView(APIView):
    def get(self, request, *args, **kwargs):
        connected_clients = []
        enabled_clients = (
            IRCClient.objects.filter(user=request.user).filter(is_enabled=True).all()
        )
        for client in enabled_clients:
            connection = all_connections[client.pk]
            if connection is not None:
                connected_clients.append(client.serialize())
        return Response({"clients": connected_clients})
