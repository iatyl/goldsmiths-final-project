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
    assigns = %{}
    ~H"<%= markup %>"
  end
end
