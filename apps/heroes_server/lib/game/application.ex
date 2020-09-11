defmodule Game.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Game.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: Game.HeroSupervisor}
    ]

    opts = [strategy: :rest_for_one, name: Game.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
