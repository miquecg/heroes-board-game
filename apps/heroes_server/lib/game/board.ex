defmodule Game.Board do
  @moduledoc """
  Board struct definition and utility functions to work with them.
  """

  alias __MODULE__
  alias GameError.BadSize

  @typedoc """
  Walkable board cell
  """
  @type tile :: {non_neg_integer(), non_neg_integer()}

  @typedoc """
  Cell where heroes cannot walk in.
  """
  @type wall :: tile

  @typedoc """
  Board dimension.
  """
  @type axis :: Range.t(0, non_neg_integer())

  @typedoc """
  A board specification.
  """
  @type t :: %__MODULE__{
          x_axis: axis,
          y_axis: axis,
          walls: MapSet.t(wall)
        }

  @enforce_keys [:x_axis, :y_axis, :walls]

  defstruct @enforce_keys

  @typedoc """
  Allowed movements.
  """
  @type move :: :up | :down | :left | :right

  defguard is_move(action) when action in [:up, :down, :left, :right]
  defguardp distance_radius_one(a, b) when abs(a - b) <= 1

  @doc """
  Create a board struct from given options.

  Requires a positive number of `cols`,
  `rows` and optionally a list of `t:wall/0`.
  """
  @spec new(keyword()) :: t
  def new(opts) do
    cols = fetch!(opts, :cols)
    rows = fetch!(opts, :rows)
    walls = Keyword.get(opts, :walls, [])

    %Board{
      x_axis: 0..(cols - 1),
      y_axis: 0..(rows - 1),
      walls: MapSet.new(walls)
    }
  end

  @spec fetch!(keyword(), atom()) :: pos_integer()
  defp fetch!(opts, size) do
    value = Keyword.fetch!(opts, size)

    if is_integer(value) and value > 0 do
      value
    else
      raise BadSize, size: size, value: value
    end
  end

  @doc """
  Generate all tiles in a board.
  """
  @spec generate(t) :: list(tile)
  def generate(%Board{x_axis: x_axis, y_axis: y_axis, walls: walls}) do
    for x <- x_axis, y <- y_axis, {x, y} not in walls, do: {x, y}
  end

  @doc """
  Play a `move`.

  `tile` is the starting point.
  """
  @spec play(t, tile, move) :: tile
  def play(%Board{} = board, tile, move) do
    tile
    |> compute(move)
    |> validate(board)
  end

  @spec compute(tile, move) :: %{from: tile, to: {integer(), integer()}}
  defp compute({x, y} = current, move) do
    next =
      case move do
        :up -> {x, y + 1}
        :down -> {x, y - 1}
        :left -> {x - 1, y}
        :right -> {x + 1, y}
      end

    %{from: current, to: next}
  end

  @spec validate(%{from: tile, to: {integer(), integer()}}, t) :: tile
  defp validate(%{from: current, to: {x, y} = next}, board) do
    cond do
      x not in board.x_axis -> current
      y not in board.y_axis -> current
      next in board.walls -> current
      true -> next
    end
  end

  @doc """
  Check wether two tiles are within one tile
  radius distance from each other.
  """
  @spec attack_distance?(tile, tile) :: boolean()
  def attack_distance?({x1, y1}, {x2, y2})
      when distance_radius_one(x1, x2) and distance_radius_one(y1, y2),
      do: true

  def attack_distance?(_, _), do: false
end
