defmodule Game.HeroServer do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  use GenServer, restart: :transient

  require Logger

  alias Game.Board

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Board.tile(),
           alive: boolean()
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board, :tile]

    defstruct [alive: true] ++ @enforce_keys
  end

  @doc """
  Spawn a hero.

  Requires options `:board` and `:tile`.

  Can be registered under a `:name`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    case Keyword.pop(opts, :name) do
      {nil, opts} -> GenServer.start_link(__MODULE__, opts)
      {name, opts} -> GenServer.start_link(__MODULE__, opts, name: name)
    end
  end

  ## Callbacks

  @impl true
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    board = Keyword.fetch!(opts, :board)
    tile = Keyword.fetch!(opts, :tile)

    {:ok, %State{board: board, tile: tile}}
  end

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call(_action, _from, %State{alive: false} = state) do
    {:reply, {:error, :noop}, state}
  end

  @impl true
  def handle_call({:play, move}, _from, %State{tile: tile, board: board} = state) do
    result = board.play(tile, move)
    {:reply, {:ok, result}, %{state | tile: result}}
  end

  @impl true
  def handle_call({:attack, enemies}, _from, state) do
    # :erlang.send/2 is asynchronous and safe
    # https://erlang.org/doc/reference_manual/processes.html#message-sending
    Enum.each(enemies, &send(&1, {:fire, state.tile}))
    {:reply, {:ok, :released}, state}
  end

  @impl true
  def handle_info({:fire, enemy_tile}, state) do
    state =
      case Board.attack_distance?(state.tile, enemy_tile) do
        true -> %{state | alive: false}
        false -> state
      end

    {:noreply, state}
  end
end
