from triotp.helpers import current_module
from triotp import application
from . import sv



__module__ = current_module()


def spec():
    return application.app_spec(
        module=__module__,
        start_arg=None,
        permanent=False,
    )


async def start(_start_arg):
    await sv.start()

