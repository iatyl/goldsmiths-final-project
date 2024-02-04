defmodule Irchub.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Irchub.Chat` context.
  """

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    {:ok, client} =
      attrs
      |> Enum.into(%{
        channels: "some channels",
        full_name: "some full_name",
        irchub_user_id: 42,
        is_enabled: true,
        nick: "some nick",
        tag: "some tag",
        url: "some url"
      })
      |> Irchub.Chat.create_client()

    client
  end
end
