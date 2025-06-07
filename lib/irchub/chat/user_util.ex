defmodule Irchub.Chat.UserUtil do
  alias Irchub.Chat.Irc.ConnectionPool
  import Ecto.Query, only: [from: 2]
  def ensure_clients(user) do
    q = from c in Irchub.Chat.Client,
          select: c,
          where: c.irchub_user_id == ^user.id

    Irchub.Repo.all(q)
    |> Enum.each(
      fn c ->
        ConnectionPool.ensure(c.id)
      end
      )
    user.id
  end
end
