defmodule Irchub.Exirc do
  def userlist(pid, channel) do
    if pid != nil && ExIRC.Client.is_connected?(pid) && Enum.member?(ExIRC.Client.channels(pid), channel) do
      ExIRC.Client.channel_users(pid, channel)
    else
      []
    end
  end
end
