defmodule HeroesServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Game.TaskSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Game.HeroSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Game.Supervisor)
  end
end
