defmodule Tictac.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Telemetry supervisor
      TictacWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tictac.PubSub},
      # setup for clustering
      {Cluster.Supervisor, [topologies, [name: Tictac.ClusterSupervisor]]},
      # Start the registry for tracking running games
      {Horde.Registry, [name: Tictac.GameRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: Tictac.DistributedSupervisor,
         shutdown: 1000,
         strategy: :one_for_one,
         members: :auto
       ]},
      # Start the Endpoint (http/https)
      TictacWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tictac.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TictacWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
