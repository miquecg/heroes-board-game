defmodule Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  @movements [:up, :down, :left, :right]

  use GenServer

  @typep state :: %__MODULE__.State{
           board: module(),
           tile: Board.Spec.tile(),
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

  Returns current tile on the board.
  """
  @spec control(GenServer.server(), atom()) :: {:ok, Board.Spec.tile()}
  def control(pid, cmd), do: GenServer.call(pid, cmd)

  ## Server (callbacks)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(cmd, _from, %State{tile: tile} = state) when cmd in @movements do
    result =
      tile
      |> compute(cmd)
      |> move(state)

    {:reply, {:ok, result}, %{state | tile: result}}
  end

  @spec compute(Board.Spec.tile(), atom()) :: Board.Spec.tile()
  defp compute({x, y}, :up), do: {x, y + 1}
  defp compute({x, y}, :down), do: {x, y - 1}
  defp compute({x, y}, :left), do: {x - 1, y}
  defp compute({x, y}, :right), do: {x + 1, y}

  @spec move(Board.Spec.tile(), state) :: Board.Spec.tile()
  defp move(to_tile, %State{tile: from_tile, board: board}) do
    case board.valid?(to_tile) do
      true -> to_tile
      false -> from_tile
    end
  end
end
