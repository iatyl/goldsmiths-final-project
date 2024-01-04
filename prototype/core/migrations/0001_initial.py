# Generated by Django 4.2.6 on 2023-11-01 03:01

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="IRCClient",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("server", models.CharField(max_length=255)),
                ("is_ssl", models.BooleanField(default=True)),
                ("port", models.IntegerField(default=6697)),
                ("nick", models.CharField(max_length=100)),
                ("real_name", models.CharField(max_length=100)),
                ("sasl_login", models.CharField(max_length=125)),
                ("sasl_passwd", models.CharField(max_length=125)),
                ("is_enabled", models.BooleanField(default=True)),
                ("_join_list", models.JSONField(default=list)),
                (
                    "user",
                    models.ForeignKey(
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]