from django.contrib import admin

from .models import IRCClient, IRCEvent


# Register your models here.
@admin.register(IRCClient)
class IRCClientAdmin(admin.ModelAdmin):
    list_display = (
        "username",
        "network",
        "nick",
        "sasl_status",
        "secure",
        "is_enabled",
    )

    @admin.display(description="User Name")
    def username(self, obj):
        return obj.user.username

    @admin.display(description="Network")
    def network(self, obj):
        return obj.name or obj.server

    @admin.display(description="Nick")
    def username(self, obj):
        return obj.nick

    @admin.display(description="SASL Ready")
    def sasl_status(self, obj):
        return "YES" if bool(obj.sasl_login and obj.sasl_passwd) else "NO"

    @admin.display(description="Secure")
    def secure(self, obj):
        return "YES" if obj.is_ssl else "NO"


@admin.register(IRCEvent)
class IRCEventAdmin(admin.ModelAdmin):
    list_display = (
        "event_type_",
        "nick",
        "origin",
        "target",
        "arguments",
        "happened_at",
    )

    @admin.display(description="Type")
    def event_type_(self, obj):
        return (obj.event_type or "").upper()

    @admin.display(description="Nick")
    def nick(self, obj):
        return (obj.event_source or "").split("!")[0]

    @admin.display(description="Origin")
    def origin(self, obj):
        return (obj.event_source or "").split("!")[-1]

    @admin.display(description="Target")
    def target(self, obj):
        return obj.event_target

    @admin.display(description="Args")
    def arguments(self, obj):
        return ", ".join(obj.event_arguments)

    @admin.display(description="Happened At")
    def happened_at(self, obj):
        return str(obj.inserted_at)
