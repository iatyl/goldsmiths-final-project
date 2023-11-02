from django.contrib import admin

from .models import IRCClient, IRCEvent


# Register your models here.
@admin.register(IRCClient)
class IRCClientAdmin(admin.ModelAdmin):
    ...


@admin.register(IRCEvent)
class IRCEventAdmin(admin.ModelAdmin):
    ...
