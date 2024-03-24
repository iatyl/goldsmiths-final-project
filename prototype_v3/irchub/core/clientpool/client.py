import trio
from cmath import inf
from . import gens
from rich import print

async def run():
    ping = await gens.ping("OK")
    print(ping)
    await trio.sleep(inf)
    await gens.stop()
