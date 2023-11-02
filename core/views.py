import datetime

from django.utils import timezone
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import IRCClient, IRCEvent


class ConnectedClientsView(APIView):
    def get(self, request, *args, **kwargs):
        connected_clients = []
        enabled_clients = (
            IRCClient.objects.filter(user=request.user).filter(is_enabled=True).all()
        )
        for client in enabled_clients:
            connection = client.get_connection()
            if connection is not None:
                connected_clients.append(client.serialize())
        return Response({"clients": connected_clients})


class ChannelMessageView(APIView):
    def get(self, request, *args, **kwargs):
        client_pk = request.data.get("client_pk")
        channel = request.data.get("channel")
        offset_timestamp = int(request.data.get("offset_timestamp"))
        client = (
            IRCClient.objects.filter(is_enabled=True)
            .filter(user=request.user)
            .filter(pk=client_pk)
            .first()
        )
        if client is None:
            return Response({"messages": [], "error": "no such client"})
        events = (
            IRCEvent.objects.filter(client=client)
            .filter(event_target=channel)
            .filter(event_type="pubmsg")
            .filter(
                inserted_at__gt=timezone.make_aware(
                    datetime.datetime.fromtimestamp(offset_timestamp)
                )
            )
            .order_by("-inserted_at")
            .all()
        )
        messages = [event.serialize() for event in events]
        return Response({"messages": messages, "error": None})
