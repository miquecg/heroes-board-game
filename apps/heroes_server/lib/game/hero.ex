defmodule Game.Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  """

  use GenServer, restart: :transient

  alias Game.Board

  @type request :: {:attack, Game.attack()} | {Board.move(), Game.update()}
  @type result :: Board.tile() | :released
  @type noop :: :noop

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

    Registry.register(Registry.Game, "board", [])

    {:ok, %State{board: board, tile: tile}}
  end

  @spec handle_call(request, GenServer.from(), state) :: {:reply, result | noop, state}
  def handle_call(msg, from, state)

  @impl true
  # Update to Elixir 1.11 `map.field` syntax in guards
  def handle_call(_action, _from, %State{alive: false} = state) do
    {:reply, :noop, state}
  end

  @impl true
  def handle_call({:attack, launcher}, _from, state) do
    launcher.(self(), state.tile)
    {:reply, :released, state}
  end

  @impl true
  def handle_call({move, updater}, _from, %State{tile: tile, board: board} = state) do
    result = board.play(tile, move)
    updater.(result)
    {:reply, result, %{state | tile: result}}
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
