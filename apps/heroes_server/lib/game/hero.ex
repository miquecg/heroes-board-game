defmodule Game.Hero do
  @moduledoc """
  Client API of `Game.HeroServer`.
  """

  alias Game.{Board, HeroServer}
  alias GameError.BadCommand

  @moves [:up, :down, :left, :right]

  @doc """
  Send a command to control a hero.

  `server` is the hero reference and `cmd`
  can be `t:Game.Board.moves/0` or atom `:attack`.

  Returns `{:ok, tile}`, `{:ok, :launched}` or
  `{:error, :noop}` when hero is dead and
  cannot execute any further actions.

  For invalid commands returns exception
  `GameError.BadCommand` in the error tuple.
  """
  @spec control(GenServer.server(), term()) :: {:ok, tile | :launched} | {:error, error}
        when tile: Board.tile(), error: :noop | %BadCommand{}
  def control(server, cmd)

  def control(server, cmd) when cmd in @moves, do: GenServer.call(server, {:play, cmd})

  def control(server, :attack) do
    children = Supervisor.which_children(Game.HeroSupervisor)

    enemies =
      Enum.flat_map(children, fn
        {_, ^server, :worker, [HeroServer]} -> []
        {_, hero, :worker, [HeroServer]} -> [hero]
      end)

    GenServer.call(server, {:broadcast, enemies})
  end

  def control(_, _), do: {:error, %BadCommand{}}

  @doc """
  Get current hero position.
  """
  @spec position(GenServer.server()) :: Board.tile()
  def position(server), do: GenServer.call(server, :position)
end
