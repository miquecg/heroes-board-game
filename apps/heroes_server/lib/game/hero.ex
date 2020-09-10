defmodule Game.Hero do
  @moduledoc """
  Client API of `Game.HeroServer`.
  """

  alias Game.{Board, HeroServer, HeroSupervisor}
  alias GameError.BadCommand

  @moves [:up, :down, :left, :right]

  @doc """
  Send a command to control a hero.

  `server` is the hero reference and
  `cmd` is the action to be executed.

  Valid commands:

  - `t:Game.Board.moves/0` returns `{:ok, tile}`
  - `:attack` returns `{:ok, :released}`

  Errors:

  - `{:error, :noop}` when hero is dead and
  cannot execute any further actions
  - `{:error, GameError.BadCommand}` for
  invalid commands
  """
  @spec control(GenServer.server(), term()) :: {:ok, result} | {:error, error}
        when result: Board.tile() | :released,
             error: :noop | %BadCommand{}
  def control(server, cmd)

  def control(server, cmd) when cmd in @moves, do: GenServer.call(server, {:play, cmd})

  def control(server, :attack) do
    children = Supervisor.which_children(HeroSupervisor)

    enemies =
      Enum.flat_map(children, fn
        {_, ^server, :worker, [HeroServer]} -> []
        {_, hero, :worker, [HeroServer]} -> [hero]
      end)

    GenServer.call(server, {:attack, enemies})
  end

  def control(_, _), do: {:error, %BadCommand{}}

  @doc """
  Get current hero position.
  """
  @spec position(GenServer.server()) :: Board.tile()
  def position(server), do: GenServer.call(server, :position)
end
