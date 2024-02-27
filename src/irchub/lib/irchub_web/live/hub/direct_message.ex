defmodule IrchubWeb.HubLive.DirectMessage do
  alias Irchub.Chat.Irc.ConnectionBaseHandler
  use IrchubWeb, :live_view

  alias Irchub.Chat
  alias Irchub.Chat.Client
  alias Irchub.Chat.Irc.ConnectionPool
  def topic(client_id, nick) do
    ConnectionPool.by_id(client_id)
    |> ConnectionBaseHandler.unique_id(nick)
  end

  @impl true
  def mount(params, _session, socket) do
    client_id = Map.get(params, "client_id") |> String.to_integer
    nick = Map.get(params, "nick")
    client_tag = Irchub.Repo.get!(Client, client_id).tag
    client = ConnectionPool.by_id(client_id) |> ExIRC.Client.state
    if connected?(socket) do
      IrchubWeb.Endpoint.subscribe(topic(client_id, nick))
    end

    {:ok, socket
      |> assign(:client_state, client)
      |> assign(:client_id, client_id)
      |> assign(:nick, nick)
      |> assign(:client_tag, client_tag)
      |> assign(:page_title, "Chatting with " <> nick)
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
    socket
  end

  @impl true
  def handle_info(%{event: "received", payload: message}, socket) do
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end
  @impl true
  def handle_event("send", %{"message" => message}, socket) do
    client_id = socket.assigns.client_id
    nick = socket.assigns.nick
    IrchubWeb.Endpoint.broadcast(
      topic(client_id, nick),
      "received",
      %{message: message, name: Irchub.Util.pval(socket.assigns.client_state, :user)}
      )
    ConnectionPool.by_id(socket.assigns.client_id)
    |> ExIRC.Client.msg(:privmsg, nick, message)
    {:noreply, socket}
  end
end
