defmodule Irchub.Chat.ClientUtil do
  @sample_state_string """
  [
  server: "irc.libera.chat",
  port: 6697,
  nick: "tesssstclient",
  pass: "",
  user: "tesssstclient",
  name: "tesssstclient",
  autoping: true,
  ssl?: true,
  connected?: true,
  logged_on?: true,
  channel_prefixes: ["#"],
  user_prefixes: [{111, 64}, {118, 43}],
  channels: [
    {"#linux",
     [
       users: ["ACuriousMoose", "AKTheKnight3", "AMG", "APic", "ASap",
        "A_Dragon", "Abrax", "AciD", "Ad0", "Adeline", "Adran", "Affliction",
        "Ahnberg", "AkechiShiro", "Aleksejs", "AlexKalopsia1945", "AlexM_",
        "Allie`", "Aminautf", "AndyCap", "Anjor", "Ankhers", "Anonamy",
        "Anth0mk", "ArchDave", "Argorok", "Ariana69", "Arisha", "Armand",
        "Arohyn", "Arokh", "Arsen", "Aryan", ...],
       topic: "Welcome to #linux! Help & support for any Linux distribution or related topic -- Rules/Info: https://linux.chat -- Forum: https://linux.forum -- Pastebin: https://paste.linux.chat/ -- @linux.social on Mastodon: https://linux.social -- Need an op? !ops <reason> or join #linux-ops",
       type: :private
     ]}
  ],
  network: "Libera.Chat",
  login_time: {1707, 104266, 748482},
  debug?: false,
  event_handlers: []
  ]
  """
  alias ExIRC.Client
  alias Irchub.Chat.Irc.Connection
  def all_states() do
    Irchub.Repo.all(Client)
    |> Enum.each(&current_state/1)
    |> Enum.filter(fn s -> s != nil end)
    |> Enum.each(fn s -> s ++ [channel_names: Enum.each(Tuple.to_list(s.channels), &Enum.at(&1, 0))] end)

  end
  def current_state(client) do
    pid = Connection.get_pid(client)
    if pid == nil do
      nil
    else
      ExIRC.Client.state pid
    end
  end
  def network(client) do
    nw = String.trim(Enum.at(Tuple.to_list(List.keyfind(Irchub.Chat.ClientUtil.current_state(client), :network, 0)), 1))
    if String.length(nw) == 0, do: client.tag, else: nw
  end
  def list_channels(client) do
    pid = Connection.get_pid(client)
    if pid == nil do
      []
    else
      ExIRC.Client.state(pid)
      |> List.keyfind(:channels, 0)
      |> Tuple.to_list
      |> Enum.at(1)
      |> Enum.map(fn t -> t |> Tuple.to_list |> Enum.at(0) end)
    end

  end
end
