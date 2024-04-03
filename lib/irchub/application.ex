defmodule Irchub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IrchubWeb.Telemetry,
      Irchub.Repo,
      {DNSCluster, query: Application.get_env(:irchub, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Irchub.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Irchub.Finch},
      # Start a worker by calling: Irchub.Worker.start_link(arg)
      # {Irchub.Worker, arg},
      # Start to serve requests, typically the last entry
      IrchubWeb.Endpoint,
      {DynamicSupervisor, name: Irchub.DynamicSupervisor, strategy: :one_for_one},
      {Irchub.Chat.Irc.ConnectionPool, []},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Irchub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IrchubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
