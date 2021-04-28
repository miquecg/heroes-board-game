defmodule Game.Hero do
  @moduledoc """
  Entity the player uses to play the game.
  """

  use GenServer, restart: :transient

  require Logger

  alias Game.Board

  @typep attack_callback :: (pid(), Board.tile() -> :ok)
  @typep move_callback :: (Board.tile() -> :ok)

  @typep request :: {:attack, attack_callback} | {Board.move(), move_callback}
  @typep reply :: Board.tile() | :released

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Board.tile()
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board, :tile]

    defstruct @enforce_keys
  end

  @doc """
  Spawn a hero.

  Requires options `:board` and `:tile`.

  Process can be registered with `:name`.
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

    {:ok, _} = Registry.register(Registry.Game, "board", nil)

    {:ok, %State{board: board, tile: tile}}
  end

  @spec handle_call(request, GenServer.from(), state) :: {:reply, reply, state}
  def handle_call(msg, from, state)

  @impl true
  def handle_call({:attack, launcher}, _from, %State{} = state) do
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
  @spec handle_info({:fire, Board.tile()}, state) :: {:stop, :shutdown, state} | {:noreply, state}
  def handle_info({:fire, enemy_tile}, %State{} = state) do
    if Board.attack_distance?(state.tile, enemy_tile),
      do: {:stop, :shutdown, state},
      else: {:noreply, state}
  end

  @spec terminate(term(), state) :: :ok
  def terminate(reason, state)

  @impl true
  def terminate(:shutdown, %State{tile: {x, y}}) do
    Registry.unregister(Registry.Game, "board")
    Logger.info("Killed hero in position x:#{x} y:#{y}")
  end

  @impl true
  def terminate(_reason, _state), do: :ok
end
