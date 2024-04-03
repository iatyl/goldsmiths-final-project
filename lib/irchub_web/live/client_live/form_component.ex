defmodule IrchubWeb.ClientLive.FormComponent do
  use IrchubWeb, :live_component

  alias Irchub.Chat

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage client records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="client-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:irchub_user_id]} type="hidden" label="" value={@current_user.id}/>
        <.input field={@form[:tag]} type="text" label="Tag" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:nick]} type="text" label="Nick" />
        <.input field={@form[:full_name]} type="text" label="Full name" />
        <.input field={@form[:is_enabled]} type="checkbox" label="Is enabled" />
        <.input field={@form[:channels]} type="text" label="Channels" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Client</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{client: client} = assigns, socket) do
    changeset = Chat.change_client(client)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"client" => client_params}, socket) do
    current_user_id = Map.get(socket.assigns, :current_user, %{}) |> Map.get(:id) || -1
    current_user_id = current_user_id |> Integer.to_string
    user_id = if Map.get(client_params, "irchub_user_id") == current_user_id do
      current_user_id
    else
      -1
    end
    client_params = Map.put(client_params, "irchub_user_id", user_id)

    changeset =
      socket.assigns.client
      |> Chat.change_client(client_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    save_client(socket, socket.assigns.action, client_params)
  end

  defp save_client(socket, :edit, client_params) do
    case Chat.update_client(socket.assigns.client, client_params) do
      {:ok, client} ->
        notify_parent({:saved, client})

        {:noreply,
         socket
         |> put_flash(:info, "Client updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_client(socket, :new, client_params) do
    case Chat.create_client(client_params) do
      {:ok, client} ->
        notify_parent({:saved, client})

        {:noreply,
         socket
         |> put_flash(:info, "Client created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
