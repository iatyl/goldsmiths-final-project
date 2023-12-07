from django.urls import include, path

from . import views

app_name = "core"

api_urlpatterns = [
    path("channel-info/", views.ChannelInfoView.as_view(), name="channel_info"),
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
    path(
        "send-message/",
        views.SendMessageView.as_view(),
        name="send_message",
    ),
]

urlpatterns = [
    path("api/", include(api_urlpatterns)),
    path("<str:path>", views.FrontendView.as_view()),
    path("", views.FrontendView.as_view()),
]
