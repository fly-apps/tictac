defmodule Tictac.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    env = Application.get_env(:tictac, :env)

    children = [
      # Start the Telemetry supervisor
      TictacWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tictac.PubSub},
      # setup for clustering
      {Cluster.Supervisor, [libcluster(env), [name: Tictac.ClusterSupervisor]]},
      # Start the registry for tracking running games
      # {Horde.Registry, name: Tictac.GameRegistry, keys: :unique, members: registry_members},
      # {Horde.DynamicSupervisor,
      #  name: Tictac.DistributedSupervisor, strategy: :one_for_one, members: supervisor_members},
      {Horde.Registry, [name: Tictac.GameRegistry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Tictac.DistributedSupervisor, strategy: :one_for_one, members: :auto]},
      # # Start the Endpoint (http/https)
      TictacWeb.Endpoint
      # Start a worker by calling: Tictac.Worker.start_link(arg)
      # {Tictac.Worker, arg}
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

  defp libcluster(:prod) do
    Logger.info("Using libcluster(:prod) mode. DNSPoll strategy")

    app_name =
      System.get_env("FLY_APP_NAME") ||
        raise "FLY_APP_NAME not available"

    [
      topologies: [
        fly6pn: [
          strategy: Cluster.Strategy.DNSPoll,
          config: [
            polling_interval: 5_000,
            query: "#{app_name}.internal",
            node_basename: app_name
          ]
        ]
      ]
    ]
  end

  defp libcluster(:test), do: []

  defp libcluster(other) do
    Logger.info("Using libcluster(_) mode with #{inspect(other)}. Empd strategy")

    [
      topologies: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:"a@127.0.0.1", :"b@127.0.0.1"]]
      ]
    ]
  end
end
