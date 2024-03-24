import requests
from triotp.helpers import current_module
from triotp import gen_server
import asyncio
import json
from multiprocessing import Process
import trio


__module__ = current_module()


async def start():
    await gen_server.start(__module__, init_arg=None, name=__name__)


async def ping(message):
    return await gen_server.call(__name__, ('ping', message))


async def task_scanner():
    return await gen_server.cast(__name__, 'task_scanner')

async def stop():
    await gen_server.cast(__name__, 'stop')


async def init(_init_arg):

    return 'nostate'


async def terminate(reason, state):
    print('exited with reason', reason, 'and state', state)


async def handle_call(message, _caller, state):
    match message:
        case ('ping', message):
            return (gen_server.Reply(f"PONG: {message}"), state)
        case _:
            exc = NotImplementedError('unkown command')
            return (gen_server.Reply(exc), state)

async def scan_and_do_tasks():
    try:
        resp = requests.get("http://127.0.0.1:8000", timeout=3)
         
async def handle_cast(message, state):
    match message:
        case 'stop':
            return (gen_server.Stop(), state)
        case 'task_scanner':
            while True:
                await scan_and_do_tasks()
                await trio.sleep(1)
            return (None, state)
        case _:
            exc = NotImplementedError('unknown command')
            return (gen_server.Stop(exc), state)