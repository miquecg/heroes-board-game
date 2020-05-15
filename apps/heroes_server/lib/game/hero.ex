defmodule Game.Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  use GenServer, restart: :temporary

  alias Game.{Board, BoardRange}
  alias GameError.BadCommand

  @moves [:up, :down, :left, :right]
  @actions [:play, :broadcast]

  @alive_status :alive
  @dead_status :dead

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Board.tile(),
           attack_range: BoardRange.t(),
           alive: boolean()
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board, :tile]

    defstruct [:attack_range, alive: true] ++ @enforce_keys
  end

  ## Client

  @doc """
  Spawn a hero.

  Requires options `:board` and `:tile`.
  """
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  @doc """
  Send a command to control a hero.

  `pid` is the hero reference.
  `cmd` is of type `t:Game.Board.moves/0`
  or atom `:attack`.

  Returns `{:ok, tile}`, `{:ok, :launched}`
  or `{:error, :noop}` when hero is dead and
  cannot execute any command.

  For invalid commands returns exception
  `GameError.BadCommand` in the error tuple.
  """
  @spec control(GenServer.server(), term()) ::
          {:ok, tile | :launched}
          | {:error, error}
        when tile: Board.tile(), error: :noop | %BadCommand{}
  def control(pid, cmd)

  def control(pid, cmd) when cmd in @moves, do: GenServer.call(pid, {:play, cmd})

  def control(pid, :attack) do
    children = Supervisor.which_children(Game.HeroSupervisor)

    enemies =
      Enum.flat_map(children, fn
        {_, ^pid, :worker, [__MODULE__]} -> []
        {_, hero, :worker, [__MODULE__]} -> [hero]
      end)

    GenServer.call(pid, {:broadcast, enemies})
  end

  def control(_, _), do: {:error, %BadCommand{}}

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    board = Keyword.fetch!(opts, :board)
    tile = Keyword.fetch!(opts, :tile)

    {:ok, %State{board: board, tile: tile, attack_range: board.attack_range(tile)}}
  end

  @impl true
  def handle_call({msg, _}, _from, %State{alive: false} = state) when msg in @actions do
    {:reply, {:error, :noop}, state}
  end

  @impl true
  def handle_call({:play, move}, _from, %State{tile: tile, board: board} = state) do
    result = board.play(tile, move)
    new_range = board.attack_range(result)

    {:reply, {:ok, result}, %{state | tile: result, attack_range: new_range}}
  end

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call({:attack, _}, _from, %State{alive: false} = state) do
    {:reply, @dead_status, state}
  end

  @impl true
  def handle_call({:attack, enemy}, _from, %State{attack_range: attack_range} = state) do
    {living_status, state} =
      case BoardRange.member?(attack_range, enemy) do
        true -> {@dead_status, %{state | alive: false}}
        false -> {@alive_status, state}
      end

    {:reply, living_status, state}
  end
end
