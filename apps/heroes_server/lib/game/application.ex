defmodule Game.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Heroes},
      Game.BoardSubscriber,
      {Registry, keys: :duplicate, name: Registry.Game, listeners: [Game.BoardSubscriber]},
      {DynamicSupervisor,
       strategy: :one_for_one, name: Game.HeroSupervisor, max_children: max_heroes()}
    ]

    opts = [strategy: :rest_for_one, name: Game.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp max_heroes, do: Application.get_env(:heroes_server, :max_heroes, :infinity)
end
