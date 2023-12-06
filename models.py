import os
import typing as t
from datetime import datetime, timedelta
from uuid import uuid4

import sqlalchemy
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError
from sqlalchemy import orm

hasher = PasswordHasher()


class ModelException(BaseException):
    ...


class ObjectExists(ModelException):
    ...


class ObjectDoesNotExist(ModelException):
    ...


class Base(orm.DeclarativeBase):
    ...


db_path = os.path.join(os.path.dirname(__file__), "db.sqlite")
engine = sqlalchemy.create_engine(f"sqlite://{db_path}")


def insert(objs: t.List[Base]):
    with orm.Session(engine) as session:
        session.add_all(objs)
        session.commit()


def select(model, where):
    with orm.Session(engine) as session:
        stmt = sqlalchemy.select(model).where(where)
        results = list(session.scalars(stmt))
    return results


class User(Base):
    __tablename__ = "users"
    id: orm.Mapped[int] = orm.mapped_column(primary_key=True)
    username: orm.Mapped[str] = orm.mapped_column(sqlalchemy.String(300))
    password: orm.Mapped[str] = orm.mapped_column(sqlalchemy.String(300))
    nicks: orm.Mapped[t.List["Nick"]] = orm.relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    tokens: orm.Mapped[t.List["UserToken"]] = orm.relationship(
        back_populates="user", cascade="all, delete-orphan"
    )

    @classmethod
    def get_user_by_id(cls, user_id: int) -> t.Optional["User"]:
        results = select(cls, cls.id == user_id)
        if len(results) == 0:
            return None
        return results[0]

    @classmethod
    def get_user_by_username(
        cls, username: str, raise_error=False
    ) -> t.Optional["User"]:
        results = select(cls, cls.username == username)
        if len(results) == 0:
            if raise_error:
                raise ObjectDoesNotExist("no such user")
            else:
                return None
        return results[0]

    @classmethod
    def exists(cls, username: str):
        return cls.get_user_by_username(username) is not None

    @classmethod
    def create(cls, username: str, raw_password: str) -> "User":
        if cls.exists(username):
            raise ObjectExists("username exists!")
        try:
            needs_hash = hasher.check_needs_rehash(raw_password)
        except InvalidHashError:
            needs_hash = True
        if needs_hash:
            password = hasher.hash(raw_password)
        else:
            password = raw_password

        user = cls(username=username, password=password)
        insert([user])
        return user

    @classmethod
    def authenticate(cls, username: str, password: str) -> t.Optional["User"]:
        user = cls.get_user_by_username(username, raise_error=True)
        if hasher.verify(user.password, password):
            return user
        return None


class Nick(Base):
    __tablename__ = "nicks"
    id: orm.Mapped[int] = orm.mapped_column(primary_key=True)
    network: orm.Mapped[str] = orm.mapped_column(sqlalchemy.String(400))
    nick: orm.Mapped[str] = orm.mapped_column(sqlalchemy.String(400))
    channels: orm.Mapped[t.List[str]] = orm.mapped_column(
        sqlalchemy.JSON(none_as_null=True)
    )
    user_id: orm.Mapped[int] = orm.mapped_column(sqlalchemy.ForeignKey("users.id"))
    user: orm.Mapped["User"] = orm.relationship(back_populates="nicks")

    @classmethod
    def create(
        cls, network: str, nick: str, channels: t.List[str], user: User
    ) -> "Nick":
        user_id = user.id


def generate_user_token():
    return str(uuid4())


def default_expires_at():
    return datetime.utcnow() + timedelta(days=30)


class UserToken(Base):
    __tablename__ = "user_tokens"
    id: orm.Mapped[int] = orm.mapped_column(primary_key=True)
    token: orm.Mapped[str] = orm.mapped_column(
        sqlalchemy.String(100), default_factory=generate_user_token
    )
    expires_at: orm.Mapped[datetime] = orm.mapped_column(
        sqlalchemy.DATETIME(), default_factory=default_expires_at
    )
    user_id: orm.Mapped[int] = orm.mapped_column(sqlalchemy.ForeignKey("users.id"))
    user: orm.Mapped["User"] = orm.relationship(back_populates="tokens")

    @classmethod
    def create(cls, username_or_id: t.Union[str, int]) -> str:
        if isinstance(username_or_id, str):
            user_id = User.get_user_by_username(username_or_id).id
        else:
            user_id = username_or_id
        token = cls(user_id=user_id)
        insert([token])
        return token.token


Base.metadata.create_all(engine)
