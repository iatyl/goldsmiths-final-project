import trio
from triotp import supervisor
from . import gens, client
from hypercorn.trio import serve
from hypercorn.config import Config 


async def start():
    children = [
         supervisor.child_spec(
             id="server",
             task=gens.start,
             args=[],
             restart=supervisor.restart_strategy.TRANSIENT,
         ),
        supervisor.child_spec(
            id="client",
            task=client.run,
            args=[],
            restart=supervisor.restart_strategy.TRANSIENT,
        ),
    ]
    opts = supervisor.options(
        max_restarts=3,
        max_seconds=5,
    )
    await supervisor.start(children, opts)