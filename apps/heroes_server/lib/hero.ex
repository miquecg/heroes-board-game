defmodule Hero do
  @moduledoc """
  Holds hero status and current position on the board.
  All player actions during the game happen on this GenServer.
  """

  @movements [:up, :down, :left, :right]

  use GenServer

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

  ## Movements
  `:up`, `:down`, `:left` and `:right`.

  Returns current position on the board.
  """
  @spec control(GenServer.server(), atom()) :: {:ok, Board.tile()}
  def control(pid, cmd), do: GenServer.call(pid, cmd)

  ## Server (callbacks)

  @impl true
  @spec init(term()) :: {:ok, state}
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(cmd, _from, %State{tile: tile, board: board} = state) when cmd in @movements do
    new_tile = compute_tile(cmd, tile)
    result = board.move(%{from: tile, to: new_tile})

    {:reply, {:ok, result}, %{state | tile: result}}
  end

  @spec compute_tile(atom(), Board.tile()) :: Board.tile()
  defp compute_tile(:up, {x, y}), do: {x, y + 1}
  defp compute_tile(:down, {x, y}), do: {x, y - 1}
  defp compute_tile(:left, {x, y}), do: {x - 1, y}
  defp compute_tile(:right, {x, y}), do: {x + 1, y}
end
