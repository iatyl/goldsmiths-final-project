defmodule Irchub.Util do
  import Phoenix.Component, [only: [sigil_H: 2]]
  def pval(pl, k) do
    if pl == nil do
      nil
    else
      List.keyfind(pl, k, 0)
      |> Tuple.to_list
      |> Enum.at(1)
    end
  end

  def broadcast(topic, event, data) do
    IrchubWeb.Endpoint.broadcast(topic, to_string(event), data)
  end

  def fmt(markup, nicks \\ nil, client_id \\ nil, language \\ :html) do
    assigns = %{markup: markup}
    ~H"<%= @markup %>"
  end
  def global_context do
    Application.get_env(:irchub, :gctx, %{})
  end
  def post_json(url, data \\ %{}) do
    encoded = Poison.encode!(data)
    HTTPoison.post(url, encoded, [{"Content-Type", "application/json"}])
  end
end