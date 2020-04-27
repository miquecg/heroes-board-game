defmodule Hero do
  @moduledoc """
  Holds hero status (alive or dead) and current position on the board.
  All player actions during the game happen on this GenServer.
  """

  use GenServer

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Board.tile(),
           status: :alive | :dead
         }

  defmodule State do
    @moduledoc false

    @enforce_keys [:board, :tile]
    defstruct [status: :alive] ++ @enforce_keys
  end

  ## Client

  @doc """
  Spawns a Hero.
  Requires options `:board` and `:tile`.
  """
  def start_link(opts) do
    board = Keyword.fetch!(opts, :board)
    tile = Keyword.fetch!(opts, :tile)
    GenServer.start_link(__MODULE__, %State{board: board, tile: tile})
  end

  def move(_pid, _cmd), do: {0, 1}

  ## Server (callbacks)

  @impl true
  def init(state), do: {:ok, state}
end
