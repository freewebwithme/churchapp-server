defmodule ChurchApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ChurchApp.Repo,
      # Start the Telemetry supervisor
      ChurchAppWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChurchApp.PubSub},
      # Start the Endpoint (http/https)
      ChurchAppWeb.Endpoint,
      # Start a worker by calling: ChurchApp.Worker.start_link(arg)
      {Absinthe.Subscription, ChurchAppWeb.Endpoint}
      # {ChurchApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChurchApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChurchAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
