defmodule Game.Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  alias Game.{Board, BoardRange}
  alias GameError.BadCommand

  @commands [:up, :down, :left, :right]

  @alive_status :alive
  @dead_status :dead

  use GenServer, restart: :temporary

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
  `cmd` is of type `t:Game.Board.moves/0`.

  Returns `{:ok, tile}` or `{:error, :noop}`
  when hero is dead and cannot execute more commands.

  For invalid commands returns exception
  `GameError.BadCommand` in the error tuple.
  """
  @spec control(GenServer.server(), term()) ::
          {:ok, tile}
          | {:error, error}
        when tile: Board.tile(), error: :noop | %BadCommand{}
  def control(pid, cmd)

  def control(pid, cmd) when cmd in @commands, do: GenServer.call(pid, {:command, cmd})
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
  def handle_call({:command, _}, _from, %State{alive: false} = state) do
    {:reply, {:error, :noop}, state}
  end

  @impl true
  def handle_call({:command, move}, _from, %State{tile: tile, board: board} = state) do
    result = board.play(tile, move)
    new_range = board.attack_range(result)

    {:reply, {:ok, result}, %{state | tile: result, attack_range: new_range}}
  end

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call({:attack, _}, _from, %State{alive: false} = state) do
    {:reply, {:ok, @dead_status}, state}
  end

  @impl true
  def handle_call({:attack, enemy}, _from, %State{attack_range: attack_range} = state) do
    state =
      case BoardRange.member?(attack_range, enemy) do
        true -> %{state | alive: false}
        false -> state
      end

    {:reply, {:ok, living_status(state)}, state}
  end

  @spec living_status(state) :: :alive | :dead
  defp living_status(%State{alive: true}), do: @alive_status
  defp living_status(%State{alive: false}), do: @dead_status
end
