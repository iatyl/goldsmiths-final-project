defmodule Irchub.Chat.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :channels, :string
    field :full_name, :string
    field :irchub_user_id, :integer
    field :is_enabled, :boolean, default: false
    field :nick, :string
    field :tag, :string
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:irchub_user_id, :tag, :url, :nick, :full_name, :is_enabled, :channels])
    |> validate_required([:irchub_user_id, :tag, :url, :nick, :full_name, :is_enabled, :channels])
  end
end
