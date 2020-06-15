defmodule HeroesWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: HeroesWeb.PubSub},
      HeroesWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: HeroesWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    HeroesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
