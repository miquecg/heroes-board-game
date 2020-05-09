defmodule GameBoards.Test2x2 do
  @moduledoc """
  Size: 2x2
  Walls: 1
  """

  alias Game.Board

  @board_spec %Board{
    cols: 2,
    rows: 2,
    walls: [{0, 0}]
  }

  @tiles Board.tiles(@board_spec)

  @doc """
  ## Example
  +---+---+
  |   |   |
  +---+---+
  | W |   |
  +---+---+
  """
  def tiles, do: @tiles

  def play(tile, move), do: Board.play(tile, move, @board_spec)

  def attack_range(point), do: Board.attack_range(point, @board_spec)

  def valid?(point), do: Board.valid?(point, @board_spec)
end

defmodule GameBoards.Test3x2 do
  @moduledoc """
  Size: 3x2
  Walls: 0
  """

  alias Game.Board

  @board_spec %Board{
    cols: 3,
    rows: 2,
    walls: []
  }

  @tiles Board.tiles(@board_spec)

  def tiles, do: @tiles

  def play(tile, move), do: Board.play(tile, move, @board_spec)

  def attack_range(point), do: Board.attack_range(point, @board_spec)

  def valid?(point), do: Board.valid?(point, @board_spec)
end

defmodule GameBoards.Test4x4 do
  @moduledoc """
  Size: 4x4
  Walls: 0
  """

  alias Game.Board

  @board_spec %Board{
    cols: 4,
    rows: 4,
    walls: []
  }

  @tiles Board.tiles(@board_spec)

  def tiles, do: @tiles

  def play(tile, move), do: Board.play(tile, move, @board_spec)

  def attack_range(point), do: Board.attack_range(point, @board_spec)

  def valid?(point), do: Board.valid?(point, @board_spec)
end

defmodule GameBoards.Test4x4w1 do
  @moduledoc """
  Size: 4x4
  Walls: 1
  """

  alias Game.Board

  @board_spec %Board{
    cols: 4,
    rows: 4,
    walls: [{3, 2}]
  }

  @tiles Board.tiles(@board_spec)

  @doc """
  ## Example
  +---+---+---+---+
  |   | ⠀ |   | ⠀ |
  +---+---+---+---+
  |   | ⠀ |   | W |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  """
  def tiles, do: @tiles

  def play(tile, move), do: Board.play(tile, move, @board_spec)

  def attack_range(point), do: Board.attack_range(point, @board_spec)

  def valid?(point), do: Board.valid?(point, @board_spec)
end

defmodule GameBoards.Test4x4w2 do
  @moduledoc """
  Size: 4x4
  Walls: 2
  """

  alias Game.Board

  @board_spec %Board{
    cols: 4,
    rows: 4,
    walls: [{1, 2}, {3, 2}]
  }

  @tiles Board.tiles(@board_spec)

  @doc """
  ## Example
  +---+---+---+---+
  |   | ⠀ |   | ⠀ |
  +---+---+---+---+
  |   | W |   | W |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  """
  def tiles, do: @tiles

  def play(tile, move), do: Board.play(tile, move, @board_spec)

  def attack_range(point), do: Board.attack_range(point, @board_spec)

  def valid?(point), do: Board.valid?(point, @board_spec)
end
