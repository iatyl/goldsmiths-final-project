defmodule Irchub.ChatTest do
  use Irchub.DataCase

  alias Irchub.Chat

  describe "clients" do
    alias Irchub.Chat.Client

    import Irchub.ChatFixtures

    @invalid_attrs %{channels: nil, full_name: nil, irchub_user_id: nil, is_enabled: nil, nick: nil, tag: nil, url: nil}

    test "list_clients/0 returns all clients" do
      client = client_fixture()
      assert Chat.list_clients() == [client]
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert Chat.get_client!(client.id) == client
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{channels: "some channels", full_name: "some full_name", irchub_user_id: 42, is_enabled: true, nick: "some nick", tag: "some tag", url: "some url"}

      assert {:ok, %Client{} = client} = Chat.create_client(valid_attrs)
      assert client.channels == "some channels"
      assert client.full_name == "some full_name"
      assert client.irchub_user_id == 42
      assert client.is_enabled == true
      assert client.nick == "some nick"
      assert client.tag == "some tag"
      assert client.url == "some url"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()
      update_attrs = %{channels: "some updated channels", full_name: "some updated full_name", irchub_user_id: 43, is_enabled: false, nick: "some updated nick", tag: "some updated tag", url: "some updated url"}

      assert {:ok, %Client{} = client} = Chat.update_client(client, update_attrs)
      assert client.channels == "some updated channels"
      assert client.full_name == "some updated full_name"
      assert client.irchub_user_id == 43
      assert client.is_enabled == false
      assert client.nick == "some updated nick"
      assert client.tag == "some updated tag"
      assert client.url == "some updated url"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_client(client, @invalid_attrs)
      assert client == Chat.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Chat.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Chat.change_client(client)
    end
  end
end
