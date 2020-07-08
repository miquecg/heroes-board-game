defmodule Game.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      {Task.Supervisor, name: Game.TaskSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Game.HeroSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
