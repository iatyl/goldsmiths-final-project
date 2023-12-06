import datetime
import os

from django.conf import settings
from django.http import FileResponse, Http404
from django.utils import timezone
from django.views import View
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import IRCClient, IRCEvent


class FrontendView(View):
    frontend_dir = settings.BASE_DIR / "frontend"

    def get(self, request, path="./", *args, **kwargs):
        path = path.lstrip("/")
        if os.path.isdir(os.path.join(self.frontend_dir, path)):
            path = os.path.join(self.frontend_dir, path, "index.html")
        if os.path.exists(path) is False:
            raise Http404("404 Not Found")
        file = open(path, "rb")
        return FileResponse(file)


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
    def post(self, request, *args, **kwargs):
        client_pk = request.data.get("client_pk")
        channel = request.data.get("channel")
        offset_timestamp = float(request.data.get("offset_timestamp"))
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
