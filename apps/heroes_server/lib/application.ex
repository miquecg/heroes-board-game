defmodule HeroesServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: HeroesServer.Registry},
      Game.Supervisor
    ]

    opts = [strategy: :rest_for_one, name: HeroesServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
