import os

from quart import Quart, send_from_directory
from quart.helpers import safe_join

from routes import api

app = Quart(__name__)
frontend_dir = safe_join(os.path.dirname(__file__), "frontend")


@app.route("/")
async def frontend_index():
    return await send_from_directory(frontend_dir, "index.html")


@app.route("/<path:path>")
async def frontend(path):
    if os.path.isdir(safe_join(frontend_dir, path)):
        path = os.path.join(path, "index.html")
    return await send_from_directory(frontend_dir, path)


app.register_blueprint(api.bp, url_prefix="/api")
