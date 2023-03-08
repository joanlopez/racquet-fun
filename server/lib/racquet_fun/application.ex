defmodule RacquetFun.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require EventBus

  @impl true
  def start(_type, _args) do
    # EventBus configuration
    EventBus.subscribe({RacquetFun.Auth.Consumers.UserSignedUp, ["^user_signed_up"]})

    children = [
      # Start the Ecto repository
      RacquetFun.Repo,
      # Start the Telemetry supervisor
      RacquetFunWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RacquetFun.PubSub},
      # Start the Endpoint (http/https)
      RacquetFunWeb.Endpoint,
      # Start the PromEx metrics collector
      RacquetFun.PromEx
      # Start a worker by calling: RacquetFun.Worker.start_link(arg)
      # {RacquetFun.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RacquetFun.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RacquetFunWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
