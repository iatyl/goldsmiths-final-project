defmodule Irchub.Util do
  import Phoenix.Component, [only: [sigil_H: 2]]
  def highlight_keywords(s, keywords, ignore_case? \\ false) do
    keywords
    |> Enum.filter(&String.contains?(s, &1))
    |> build_keyword_regex(ignore_case?)
    |> Regex.scan(s)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.uniq
    |> List.flatten
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.reduce(
      s,
      &String.replace(&2, &1, ~s(<i><b>#{&1}</b></i>), global: true)
      )
  end

  defp build_keyword_regex(keywords, ignore_case?) do
    reopts = if ignore_case?, do: "i", else: ""
    keywords
    |> Enum.map(&Regex.escape(&1))
    |> Enum.join("|")
    |> Kernel.<>("\\b")
    |> Kernel.<>("(?:")
    |> Kernel.<>("\\b)")
    |> Regex.compile!(reopts)
  end
  def highlight_links(s) do
    ptn = ~r(https?://\S+)
    Regex.scan(ptn, s)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.uniq
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> List.flatten
    |> Enum.reduce(
      s,
      &String.replace(
        &2,
        &1,
        ~s(<a style="text-decoration: underline; color: #000000; font-weight: bold;" href="#{&1}">#{&1}</a>),
        global: true)
      )

  end

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

  def fmt(markup, nicks \\ [], client_id \\ nil, language \\ :html) do
    # assigns = %{markup: markup
              # |> highlight_keywords(nicks, ignore_case?: true)
              # |> highlight_links
              # }
    # ~H"<%= @markup %>"
    markup
               |> highlight_keywords(nicks, ignore_case?: true)
               |> highlight_links
  end
  def global_context do
    Application.get_env(:irchub, :gctx, %{})
  end
  def post_json(url, data \\ %{}) do
    encoded = Poison.encode!(data)
    HTTPoison.post(url, encoded, [{"Content-Type", "application/json"}])
  end
  def push_github_state(state) do
    current_states = Application.get_env(:irchub, :github_states, MapSet.new())
    if MapSet.member?(current_states, state) do
      false
    else
      new_states = current_states |> MapSet.put(state)
      Application.put_env(:irchub, :github_states, new_states)
      true
    end
  end
  def pop_github_state(state) do
    current_states = Application.get_env(:irchub, :github_states, MapSet.new())
    if MapSet.member?(current_states, state) == false do
      false
    else
      new_states = MapSet.delete(current_states, state)
      Application.put_env(:irchub, :github_states, new_states)
      true
    end
  end
end
