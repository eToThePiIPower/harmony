defmodule Harmony.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Harmony.Repo,
      # Start the Telemetry supervisor
      HarmonyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Harmony.PubSub},
      # Start the Endpoint (http/https)
      HarmonyWeb.Endpoint
      # Start a worker by calling: Harmony.Worker.start_link(arg)
      # {Harmony.Worker, arg}
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
