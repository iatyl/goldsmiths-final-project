defmodule IrchubWeb.HubLive.Channel do
  alias Irchub.Chat.Irc.ConnectionBaseHandler
  use IrchubWeb, :live_view

  alias Irchub.Chat
  alias Irchub.Chat.Client
  alias Irchub.Chat.Irc.ConnectionPool
  def topic(client_id, channel) do
    ConnectionPool.by_id(client_id)
    |> ConnectionBaseHandler.unique_id(channel)
  end

  @impl true
  def mount(params, _session, socket) do
    client_id = Map.get(params, "client_id") |> String.to_integer
    channel = Map.get(params, "channel")
    client_tag = Irchub.Repo.get!(Client, client_id).tag
    client = ConnectionPool.by_id(client_id) |> ExIRC.Client.state
    if connected?(socket) do
      IrchubWeb.Endpoint.subscribe(topic(client_id, channel))
    end

    {:ok, socket
      |> assign(:client_state, client)
      |> assign(:client_id, client_id)
      |> assign(:channel, channel)
      |> assign(:client_tag, client_tag)
      |> assign(:page_title, channel)
      |> assign(:messages, [])
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Client")
    |> assign(:client, Chat.get_client!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Client")
    |> assign(:client, %Client{})
  end

  defp apply_action(socket, :index, _params) do
    client_pid = socket.assigns.client_id |> ConnectionPool.by_id
    channel = socket.assigns.channel
    # |> assign(:page_title, "Listing Clients")
    # |> assign(:client, nil)
    userlist = Irchub.Exirc.userlist(client_pid, channel)

    socket
    |> assign(:userlist, userlist)
    |> assign(:nicklist, userlist)

  end
  @impl true
  def handle_info(%{event: "received", payload: message}, socket) do
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end
  @impl true
  def handle_info(%{event: "userlist", payload: userlist}, socket) do
    {:noreply, assign(socket, userlist: userlist)}
  end

 #  @impl true
 #  def handle_info({IrchubWeb.ClientLive.FormComponent, {:saved, client}}, socket) do
 #    {:noreply, stream_insert(socket, :clients, client)}
 #  end
  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    client_id = socket.assigns.client_id
    channel = socket.assigns.channel
    IrchubWeb.Endpoint.broadcast(
      topic(client_id, channel),
      "received",
      %{message: message, name: Irchub.Util.pval(socket.assigns.client_state, :user)}
      )
    ConnectionPool.by_id(socket.assigns.client_id)
    |> ExIRC.Client.msg(:privmsg, channel, message)
    {:noreply, socket}
  end
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    client = Chat.get_client!(id)
    {:ok, _} = Chat.delete_client(client)

    {:noreply, stream_delete(socket, :clients, client)}
  end
end
