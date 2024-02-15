defmodule IrchubWeb.HubLive.Channel do
  use IrchubWeb, :live_view

  alias Irchub.Chat
  alias Irchub.Chat.Client
  alias Irchub.Chat.Irc.ConnectionPool

  @impl true
  def mount(params, _session, socket) do
    client_id = Map.get(params, "client_id") |> String.to_integer
    channel = Map.get(params, "channel")
    client_tag = Irchub.Repo.get!(Client, client_id).tag
    client = ConnectionPool.by_id(client_id) |> ExIRC.Client.state

    {:ok, socket
      |> assign(:client_state, client)
      |> assign(:channel, channel)
      |> assign(:client_tag, client_tag)
      |> assign(:page_title, channel)
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
    # |> assign(:page_title, "Listing Clients")
    |> assign(:client, nil)
  end

 #  @impl true
 #  def handle_info({IrchubWeb.ClientLive.FormComponent, {:saved, client}}, socket) do
 #    {:noreply, stream_insert(socket, :clients, client)}
 #  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    client = Chat.get_client!(id)
    {:ok, _} = Chat.delete_client(client)

    {:noreply, stream_delete(socket, :clients, client)}
  end
end
