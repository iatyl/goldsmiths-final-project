from django.urls import path

from . import views

app_name = "core"
urlpatterns = [
    path(
        "connected-clients/",
        views.ConnectedClientsView.as_view(),
        name="connected_clients",
    )
]
