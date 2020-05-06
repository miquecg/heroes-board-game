defmodule Game.Board do
  @moduledoc """
  Board struct definition and utility functions to work with them.
  """

  alias __MODULE__
  alias Game.BoardRange

  @typedoc """
  Walkable board cell
  """
  @type tile :: {non_neg_integer(), non_neg_integer()}

  @typedoc """
  Cell where heroes cannot walk in.
  """
  @type wall :: tile

  @typedoc """
  A board is defined by:

  - `cols`: number of columns
  - `rows`: number of rows
  - `walls`: list of `t:wall/0`
  """
  @type t :: %__MODULE__{
          cols: pos_integer(),
          rows: pos_integer(),
          walls: list(wall)
        }

  @enforce_keys [:cols, :rows, :walls]

  defstruct @enforce_keys

  @doc """
  Convert a `Game.Board` struct into a list of tiles.

  ## Example
  +---+---+---+---+
  | w | ⠀ | w | ⠀ |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  | w |   | w | w |
  +---+---+---+---+

      iex> alias Game.Board
      iex> Board.tiles(%Board{cols: 4, rows: 3, walls: [{0,0},{0,2},{2,0},{2,2},{3,0}]})
      [{0, 1}, {1, 0}, {1, 1}, {1, 2}, {2, 1}, {3, 1}, {3, 2}]

  """
  @spec tiles(t) :: list(tile)
  def tiles(%Board{cols: cols, rows: rows, walls: walls}) do
    for x <- 0..(cols - 1), y <- 0..(rows - 1), {x, y} not in walls, do: {x, y}
  end

  def attack_range({x, y}, %Board{cols: cols, rows: rows}) do
    x_min = max(x - 1, 0)
    x_max = min(x + 1, cols - 1)
    y_min = max(y - 1, 0)
    y_max = min(y + 1, rows - 1)

    %BoardRange{h: x_min..x_max, v: y_min..y_max}
  end

  @doc """
  Check if `point` is a valid tile in `board`.
  """
  @spec valid?(term(), t) :: boolean()
  def valid?({x, y} = point, board) when is_integer(x) and is_integer(y) do
    validators = [&cols/2, &rows/2, &tile?/2]
    Enum.all?(validators, fn fun -> fun.(point, board) end)
  end

  def valid?(_, %Board{}), do: false

  @spec cols({integer(), integer()}, t) :: boolean()
  defp cols({x, _}, %Board{cols: cols}), do: 0 <= x and x < cols

  @spec rows({integer(), integer()}, t) :: boolean()
  defp rows({_, y}, %Board{rows: rows}), do: 0 <= y and y < rows

  @spec tile?({integer(), integer()}, t) :: boolean()
  defp tile?(point, %Board{walls: walls}), do: point not in walls
end
