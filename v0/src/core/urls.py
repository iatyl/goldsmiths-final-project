from django.urls import include, path, re_path
from rest_framework.authtoken import views as authtoken_views

from . import views

app_name = "core"
api_urlpatterns = [
    path("get-token/", authtoken_views.obtain_auth_token),
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
    path("", views.FrontendView.as_view()),
    # re_path(r"(?P<path>[\w+-/@.~+:]+)$", views.FrontendView.as_view()),
]
