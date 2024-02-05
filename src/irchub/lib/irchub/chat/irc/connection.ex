defmodule Irchub.Chat.Irc.Connection do
  @appname :irchub_connection
  defp ensure_backend() do
      existing_pid = Application.get_env(:irchub, @appname)
      if existing_pid == nil do
        pid = ExIRC.start_link!
        Application.put_env(:irchub, @appname, pid)
      else
        :ok
      end
  end
  def parse_url(url) do
    data = URI.parse(url)
    valid? = Enum.member?(["irc", "ircs"], data.scheme)
    if valid? == false do
      {:invalid, nil}
    else
      ssl? = data.scheme == "ircs"
      [sasl_user, sasl_pass] = String.split(data.userinfo, ":", parts: 2)
      host = data.host
      port = data.port
      {:ok, %{
        ssl?: ssl?,
        sasl_user: sasl_user,
        sasl_pass: sasl_pass,
        host: host,
        port: port
        }}
    end
  end
  def close_connection(pid) do
      ensure_backend()
      ExIRC.Client.quit pid, "Leaving..."
      ExIRC.Client.stop! pid
  end
  def get_pid(client) do
    clients = Application.get_env(@appname, :clients, %{})
    Map.get(clients, client.id)
  end
  def disconnect(client) do
    clients = Application.get_env(@appname, :clients, %{})
    pid = Map.get(clients, client.id)
    if pid == nil do
      :ok
    else
      close_connection(pid)
      updated_clients = Map.delete(clients, client.id)
      Application.put_env(@appname, :clients, updated_clients)
    end
  end

  def make_connection(url) do
      {:ok, data} = parse_url(url)
      ensure_backend()
      {:ok, pid} = ExIRC.start_client!
      if data.ssl? do
        ExIRC.Client.connect_ssl! pid, data.host, data.port
      else
        ExIRC.Client.connect! pid, data.host, data.port
      end
      {:ok, %{pid: pid, data: data}}
  end
  def parse_channel_list(channel_list) do
    Poison.decode!(channel_list)
  end
  def wait_logon_sync(client) do
    pid = get_pid(client)
    case pid != nil && ExIRC.Client.is_logged_on? pid do
      true ->
        :ok
      false ->
        :timer.sleep(300)
        wait_logon_sync(client)
    end
  end
  def ensure_connected(client) do
    existing_clients = Application.get_env(@appname, :clients, %{})
    existing_pid = Map.get(existing_clients, client.id)
    if existing_pid == nil do
      {:ok, result} = make_connection(client.url)
      pid = result.pid
      data = result.data
      ExIRC.Client.logon(
          pid,
          data.sasl_pass,
          client.nick,
          data.sasl_user,
          client.full_name
        )
      channel_list = parse_channel_list(client.channels)
      Task.async(fn ->
        wait_logon_sync(client)
        Enum.each(channel_list, fn c -> ExIRC.Client.join pid, c end)
      end)
      store_pid(client, pid)
      pid
    else
      existing_pid
    end
  end
  def store_pid(client, pid) do
    clients = Application.get_env(@appname, :clients, %{})
    updated_clients = Map.put(clients, client.id, pid)
    Application.put_env(@appname, :clients, updated_clients)
  end
end
