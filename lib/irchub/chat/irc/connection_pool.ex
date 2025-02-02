defmodule Irchub.Chat.Irc.ConnectionPool do
  use GenServer
  @server_name __MODULE__

  def name, do: @server_name

  def start_link(_opts) do
    GenServer.start_link __MODULE__, [], name: @server_name
  end

  def child_spec(_args) do
    %{
      id: Irchub.Chat.Irc.ConnectionPool,
      start: {Irchub.Chat.Irc.ConnectionPool, :start_link, [nil]},
    }
  end

  @impl true
  def init(_) do
    initial_state = %{clients: %{}}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def all_clients do
    GenServer.call(__MODULE__, :state)
    |> Map.get(:clients)
    |> Enum.map(fn {k, v} -> {k, v.client} end)
    |> Enum.into(%{})
    |> Map.filter(fn {_, v} -> ExIRC.Client.is_connected? v end)
  end
  def by_handler(pid, type \\ :base_handler) do
    GenServer.call(__MODULE__, :state)
    |> Map.get(:clients)
    |> Map.filter(fn {_, pids} -> Map.get(pids.handlers, type) == pid end)
    |> Enum.map(fn {_, v} -> v.client end)
    |> Enum.at(0)

  end
  def by_id(client_id) do
    GenServer.call(__MODULE__, :state)
    |> Map.get(:clients)
    |> Map.get(client_id, %{})
    |> Map.get(:client)
  end
  def ensure(client_id) do
    pid = by_id(client_id)
    if pid == nil || !Process.alive?(pid) do
      spawn_client(client_id)
    else
      pid
    end
  end

  def spawn_client(client_id) do
    GenServer.cast(__MODULE__, {:spawn, client_id})
    by_id(client_id)
  end
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
  def kill(client_id) do
    GenServer.cast(__MODULE__, {:kill, client_id})
  end
  @impl true
  def handle_cast({:spawn, client_id}, state) do
    clients = Map.get(state, :clients)
    client = Irchub.Repo.get(Irchub.Chat.Client, client_id)
    if client != nil do
      pids = connect(client)
      clients = Map.put(clients, client_id, pids)
      new_state = Map.put(state, :clients, clients)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:kill, client_id}, state) do
     clients = state |> Map.get(:clients)
     pids = clients |> Map.get(client_id)
     pid = pids.client
     if pid != nil && Process.alive?(pid) do
       ExIRC.Client.quit pid, "Leaving..."
       ExIRC.Client.stop! pid
     end
     if Map.has_key?(clients, client_id) do
       new_state = state |> Map.put(:clients, Map.delete(clients, client_id))
       {:noreply, new_state}
     else
       {:noreply, state}
     end

  end

  defp parse_channel_list(channel_list) do
    Poison.decode!(channel_list)
  end
  defp parse_url(url) do
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
  def wait_logon_sync(client, timeout \\ 30000) do
    if timeout >= 0 do
      pid = if Kernel.is_pid(client), do: client, else: by_id(client.id)
      case pid != nil && ExIRC.Client.is_logged_on? pid do
        true ->
          {:ok}
        _ ->
          :timer.sleep(300)
          wait_logon_sync(client, timeout - 300)
      end
    else
      {:timeout}
    end
  end
  def is_local(url) do
    URI.parse(url).host == "127.0.0.1"
  end
  def connect(client) do
    if Application.get_env(:irchub, :gctx).mode == :local and is_local(client.url) == false do
      {:ok, pid} = ExIRC.start_link!
      %{client: pid, handlers: %{base_handler: nil}}
    else
      do_connect(client)
    end

  end
  def do_connect(client) do
    {:ok, data} = parse_url(client.url)
    {:ok, pid} = ExIRC.start_link!
    {:ok, base_handler_pid} = Irchub.Chat.Irc.ConnectionBaseHandler.start_link(pid)
    if data.ssl? do
      ExIRC.Client.connect_ssl! pid, data.host, data.port
    else
      ExIRC.Client.connect! pid, data.host, data.port
    end
    ExIRC.Client.logon(
          pid,
          data.sasl_pass,
          client.nick,
          data.sasl_user,
          client.full_name
        )
    channel_list = parse_channel_list(client.channels)
    Task.async(fn ->
      case wait_logon_sync(client) do
          {:timeout} -> nil
          {:ok} -> Enum.each(channel_list, fn c -> ExIRC.Client.join pid, c end)
        end
      end)
    %{client: pid, handlers: %{base_handler: base_handler_pid}}
  end
end
