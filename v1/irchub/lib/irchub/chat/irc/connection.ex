defmodule Irchub.Chat.Irc.Connection do
  alias Irchub.Chat.Irc.ConnectionPool

  def get_pid(client) do
    clients = ConnectionPool.all_clients()
    pid = Map.get(clients, client.id)
    if pid != nil && Process.alive?(pid) == false do
      ConnectionPool.ensure(client.id)
    else
      pid
    end
  end
  def disconnect(client) do
    ConnectionPool.kill(client.id)
  end


end
