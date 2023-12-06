from quart import Blueprint, request
from quart.json import jsonify

bp = Blueprint("api", __name__)


@bp.route("/ping/")
async def ping():
    return jsonify({"msg": "pong"})


auth = Blueprint("auth", __name__)


@auth.route("/login/")
async def login():
    ...


@auth.route("/signup/")
async def signup():
    return ...


bp.register_blueprint(auth, url_prefix="/auth")
