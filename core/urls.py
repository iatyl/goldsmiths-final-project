from django.urls import path

from . import views

app_name = "core"
urlpatterns = [
    path(
        "connected-clients/",
        views.ConnectedClientsView.as_view(),
        name="connected_clients",
    ),
    path(
        "channel-messages/",
        views.ChannelMessageView.as_view(),
        name="channel_messages",
    ),
]
