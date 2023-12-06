from django.apps import AppConfig


class CoreConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "core"

    def ready(self):
        from django.conf import settings

        from core.models import IRCClient
        from corelibs.asyncio.utils import all_of

        connect_at_startup = getattr(settings, "IRCHUB_CONNECT_AT_STARTUP", False)
        if connect_at_startup:
            enabled_clients = all_of(IRCClient, is_enabled=True)
            for client in enabled_clients:
                client.get_connection()
