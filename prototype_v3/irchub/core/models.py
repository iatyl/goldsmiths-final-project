from django.db import models


# Create your models here.
class IRCConnection(models.Model):
    name = models.CharField(max_length=100)
    sasl_user = models.CharField(max_length=256)
    sasl_pass = models.CharField(max_length=256)
    server = models.CharField(max_length=100)  # ircs://irc.libera.chat:6697
    channels = models.JSONField(null=True, blank=True, default=list)
    inserted_at = models.DateTimeField(auto_now_add=True, editable=False)
    updated_at = models.DateTimeField(auto_now=True, editable=False)
