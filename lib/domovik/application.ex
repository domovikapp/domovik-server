defmodule Domovik.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Domovik.Repo,
      # Start the Telemetry supervisor
      DomovikWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Domovik.PubSub},
      # Start the Endpoint (http/https)
      DomovikWeb.Endpoint,
      # Start a worker by calling: Domovik.Worker.start_link(arg)
      # {Domovik.Worker, arg}
      Pow.Store.Backend.MnesiaCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Domovik.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DomovikWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
