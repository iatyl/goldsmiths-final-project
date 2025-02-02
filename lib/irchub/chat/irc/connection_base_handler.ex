defmodule Irchub.Chat.Irc.ConnectionBaseHandler do
  @moduledoc """
  IRCHub base connection handler
  """
  alias Irchub.Chat.Irc.ConnectionPool
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIRC.Client.add_handler client, Kernel.self
    {:ok, client}
  end

  @doc """
  Handle messages from the client

  Examples:

    def handle_info({:connected, server, port}, _state) do
      IO.puts "Connected to \#{server}:\#{port}"
    end
    def handle_info(:logged_in, _state) do
      IO.puts "Logged in!"
    end
    def handle_info(%ExIRC.Message{nick: from, cmd: "PRIVMSG", args: ["mynick", msg]}, _state) do
      IO.puts "Received a private message from \#{from}: \#{msg}"
    end
    def handle_info(%ExIRC.Message{nick: from, cmd: "PRIVMSG", args: [to, msg]}, _state) do
      IO.puts "Received a message in \#{to} from \#{from}: \#{msg}"
    end
  """
  def unique_id(pid, target) do
    client = ExIRC.Client.state(pid)
    user = Irchub.Util.pval(client, :user)
    "#{user}@#{target}@#{Irchub.Util.pval(client, :server)}:#{Integer.to_string(Irchub.Util.pval(client, :port))}"
  end

  def update_userlist(pid, channel) do
    Irchub.Util.broadcast(unique_id(pid, channel), :userlist, Irchub.Exirc.userlist(pid, channel))
  end
  def handle_info({:connected, server, port}, _state) do
    {:noreply, nil}
  end
  def handle_info(:logged_in, _state) do
    {:noreply, nil}
  end
  def handle_info({:login_failed, :nick_in_use}, _state) do
    {:noreply, nil}
  end
  def handle_info(:disconnected, _state) do
    {:noreply, nil}
  end
  def handle_info({:joined, channel}, _state) do
    client_pid = ConnectionPool.by_handler(Kernel.self())
    update_userlist(client_pid, channel)

    {:noreply, nil}
  end
  def handle_info({:joined, channel, user}, _state) do
    client_pid = ConnectionPool.by_handler(Kernel.self())
    update_userlist(client_pid, channel)

    {:noreply, nil}
  end
  def handle_info({:topic_changed, channel, topic}, _state) do
    {:noreply, nil}
  end
  def handle_info({:nick_changed, nick}, _state) do
    {:noreply, nil}
  end
  def handle_info({:nick_changed, old_nick, new_nick}, _state) do
    {:noreply, nil}
  end
  def handle_info({:parted, channel}, _state) do
    {:noreply, nil}
  end
  def handle_info({:parted, channel, sender}, _state) do
    client_pid = ConnectionPool.by_handler(Kernel.self())

    update_userlist(client_pid, channel)
    nick = sender.nick
    {:noreply, nil}
  end
  def handle_info({:invited, sender, channel}, _state) do
    by = sender.nick
    {:noreply, nil}
  end
  def handle_info({:kicked, sender, channel}, _state) do
    by = sender.nick
    {:noreply, nil}
  end
  def handle_info({:kicked, nick, sender, channel}, _state) do
    by = sender.nick
    client_pid = ConnectionPool.by_handler(Kernel.self())
    update_userlist(client_pid, channel)
    {:noreply, nil}
  end
  def handle_info({:received, message, sender}, _state) do
    from = sender.nick
    client_pid = ConnectionPool.by_handler(Kernel.self())
    Irchub.Util.broadcast(unique_id(client_pid, from), :received, %{name: from, message: message})
    {:noreply, nil}

  end
  def handle_info({:received, message, sender, channel}, _state) do
    from = sender.nick
    client_pid = ConnectionPool.by_handler(Kernel.self())
    Irchub.Util.broadcast(unique_id(client_pid, channel), :received, %{name: from, message: message})
    {:noreply, nil}
  end
  def handle_info({:mentioned, message, sender, channel}, _state) do
    from = sender.nick
    {:noreply, nil}
  end
  def handle_info({:me, message, sender, channel}, _state) do
    from = sender.nick
    {:noreply, nil}
  end
  # This is an example of how you can manually catch commands if ExIRC.Client doesn't send a specific message for it
  def handle_info(%ExIRC.Message{nick: from, cmd: "PRIVMSG", args: ["testnick", msg]}, _state) do
    {:noreply, nil}
  end
  def handle_info(%ExIRC.Message{nick: from, cmd: "PRIVMSG", args: [to, msg]}, _state) do
    {:noreply, nil}
  end
  # Catch-all for messages you don't care about
  def handle_info(msg, _state) do
    IO.inspect msg
    {:noreply, nil}
  end

  defp debug(msg) do
    IO.inspect msg
  end
end
