from django.contrib import admin

from .models import IRCClient


# Register your models here.
@admin.register(IRCClient)
class IRCClientAdmin(admin.ModelAdmin):
    ...
