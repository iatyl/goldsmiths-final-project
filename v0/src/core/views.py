import datetime
import os
from dataclasses import asdict

from django.conf import settings
from django.http import FileResponse, Http404
from django.utils import timezone
from django.views import View
from rest_framework.response import Response
from rest_framework.views import APIView

from core.models import ChannelInfo, IRCClient, IRCEvent


class FrontendView(View):
    frontend_dir = settings.BASE_DIR / "frontend"

    def get(self, request, path="./", *args, **kwargs):
        path = path.lstrip("/")
        path = os.path.join(self.frontend_dir, path)
        if os.path.isdir(path):
            path = os.path.join(path, "index.html")
        if os.path.exists(path) is False:
            raise Http404("404 Not Found")
        file = open(path, "rb")
        return FileResponse(file)


class ChannelInfoView(APIView):
    def post(self, request, *args, **kwargs):
        client_pk = request.data.get("client_pk")
        channel = request.data.get("channel")
        if not client_pk or not channel:
            return Response(asdict(ChannelInfo(error="bad args")), status=400)
        client = (
            IRCClient.objects.filter(is_enabled=True)
            .filter(user=request.user)
            .filter(pk=client_pk)
            .first()
        )
        if client is None:
            return Response(
                asdict(ChannelInfo(error="no such client or wrong user")), status=400
            )
        if channel not in client.join_list:
            return Response(asdict(ChannelInfo(error="channel not joined")), status=400)
        return Response(asdict(ChannelInfo(members=client.channel_members(channel))))


class SendMessageView(APIView):
    def post(self, request, *args, **kwargs):
        client_pk = request.data.get("client_pk")
        channel = request.data.get("channel")
        message = request.data.get("message")
        if not message:
            return Response({"messages": [], "error": "empty message"})
        client = (
            IRCClient.objects.filter(user=request.user)
            .filter(pk=client_pk)
            .filter(is_enabled=True)
            .first()
        )
        if client is None:
            return Response({"messages": [], "error": "no such client"})
        if channel not in client.join_list:
            return Response({"messages": [], "error": "channel not joined"})

        client.get_connection().privmsg(channel, message)
        IRCEvent.objects.create(
            client=client,
            event_type="pubmsg",
            event_source=f"{client.nick}!IRCHub",
            event_target=channel,
            event_arguments=[message],
        )

        return Response({"messages": [], "error": None})


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
