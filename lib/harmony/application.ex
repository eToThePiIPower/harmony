defmodule Harmony.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HarmonyWeb.Telemetry,
      Harmony.Repo,
      {DNSCluster, query: Application.get_env(:harmony, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Harmony.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Harmony.Finch},
      # Start a worker by calling: Harmony.Worker.start_link(arg)
      # {Harmony.Worker, arg},
      HarmonyWeb.Presence,
      # Start to serve requests, typically the last entry
      HarmonyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Harmony.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HarmonyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
