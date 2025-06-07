defmodule Irchub.Chat.Irc.ConnectionApplication do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Irchub.Chat.Irc.ConnectionPool, []},
    ]

    opts = [strategy: :one_for_one, name: Irchub.Chat.Irc.ConnectionSupervisor]
    Supervisor.start_link(children, opts)
  end
end
