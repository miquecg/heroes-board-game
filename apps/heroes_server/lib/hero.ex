defmodule Hero do
  @moduledoc """
  Holds hero status and current tile on the board.
  All player actions during the game happen on this GenServer.
  """

  @movements [:up, :down, :left, :right]
  @commands @movements

  use GenServer, restart: :temporary

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

  @typedoc """
  Supported commands for controling a hero.
  """
  @type cmd :: :up | :down | :left | :right

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

  `pid` is the hero reference and `cmd` is an atom of type `t:cmd/0`.

  Returns `{:ok, tile}` or `{:error, error}` for invalid commands.
  """
  @spec control(GenServer.server(), term()) ::
          {:ok, tile}
          | {:error, error}
        when tile: Board.Spec.tile(), error: %BadCommand{}
  def control(pid, cmd)

  def control(pid, cmd) when cmd in @commands, do: GenServer.call(pid, cmd)
  def control(_, _), do: {:error, %BadCommand{}}

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
