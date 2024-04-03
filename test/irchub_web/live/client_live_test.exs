defmodule IrchubWeb.ClientLiveTest do
  use IrchubWeb.ConnCase

  import Phoenix.LiveViewTest
  import Irchub.ChatFixtures
  import Irchub.AccountsFixtures

  @create_attrs %{channels: "some channels", full_name: "some full_name", irchub_user_id: 42, is_enabled: true, nick: "some nick", tag: "some tag", url: "some url"}
  @update_attrs %{channels: "some updated channels", full_name: "some updated full_name", irchub_user_id: 43, is_enabled: false, nick: "some updated nick", tag: "some updated tag", url: "some updated url"}
  @invalid_attrs %{channels: nil, full_name: nil, irchub_user_id: nil, is_enabled: false, nick: nil, tag: nil, url: nil}

  defp create_client(_) do
    client = client_fixture()
    %{client: client}
  end

  describe "Index" do
    setup [:create_client]

    test "lists all clients", %{conn: conn, client: client} do
      {:ok, _index_live, html} = live(conn, ~p"/clients")

      assert html =~ "Listing Clients"
      assert html =~ client.channels
    end

    test "saves new client", %{conn: conn} do
      password = "123456789abcd"
      user = user_fixture(%{password: password})

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form =
        form(lv, "#login_form", user: %{email: user.email, password: password, remember_me: true})

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
      {:ok, index_live, _html} = live(conn, ~p"/clients")

      assert index_live |> element("a", "New Client") |> render_click() =~
               "New Client"

      assert_patch(index_live, ~p"/clients/new")

      assert index_live
             |> form("#client-form", client: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#client-form", client: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/clients")

      html = render(index_live)
      assert html =~ "Client created successfully"
      assert html =~ "some channels"
    end

    test "updates client in listing", %{conn: conn, client: client} do
      {:ok, index_live, _html} = live(conn, ~p"/clients")

      assert index_live |> element("#clients-#{client.id} a", "Edit") |> render_click() =~
               "Edit Client"

      assert_patch(index_live, ~p"/clients/#{client}/edit")

      assert index_live
             |> form("#client-form", client: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#client-form", client: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/clients")

      html = render(index_live)
      assert html =~ "Client updated successfully"
      assert html =~ "some updated channels"
    end

    test "deletes client in listing", %{conn: conn, client: client} do
      {:ok, index_live, _html} = live(conn, ~p"/clients")

      assert index_live |> element("#clients-#{client.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#clients-#{client.id}")
    end
  end

  describe "Show" do
    setup [:create_client]

    test "displays client", %{conn: conn, client: client} do
      {:ok, _show_live, html} = live(conn, ~p"/clients/#{client}")

      assert html =~ "Show Client"
      assert html =~ client.channels
    end

    test "updates client within modal", %{conn: conn, client: client} do
      {:ok, show_live, _html} = live(conn, ~p"/clients/#{client}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Client"

      assert_patch(show_live, ~p"/clients/#{client}/show/edit")

      assert show_live
             |> form("#client-form", client: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#client-form", client: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/clients/#{client}")

      html = render(show_live)
      assert html =~ "Client updated successfully"
      assert html =~ "some updated channels"
    end
  end
end
