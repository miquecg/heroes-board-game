defmodule Game.Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  alias Game.Board
  alias GameError.BadCommand

  @commands [:up, :down, :left, :right]

  use GenServer, restart: :temporary

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

  ## Client

  @doc """
  Spawn a hero.

  Requires options `:board` and `:tile`.
  """
  def start_link(opts) do
    board = Keyword.fetch!(opts, :board)
    tile = Keyword.fetch!(opts, :tile)
    GenServer.start_link(__MODULE__, %State{board: board, tile: tile})
  end

  @doc """
  Send a command to control a hero.

  `pid` is the hero reference.
  `cmd` is of type `t:Game.Board.moves/0`.

  Returns `{:ok, tile}` or `{:error, error}` for invalid commands.
  """
  @spec control(GenServer.server(), term()) ::
          {:ok, tile}
          | {:error, error}
        when tile: Board.tile(), error: %BadCommand{}
  def control(pid, cmd)

  def control(pid, cmd) when cmd in @commands, do: GenServer.call(pid, {:play, cmd})
  def control(_, _), do: {:error, %BadCommand{}}

  ## Server (callbacks)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:play, move}, _from, %State{tile: tile, board: board} = state) do
    result = board.play(tile, move)

    {:reply, {:ok, result}, %{state | tile: result}}
  end

  @impl true
  def handle_call({:attack, _}, _from, state) do
    {:reply, {:ok, :dead}, state}
  end
end
