defmodule GameBoards.Test2x2w1 do
  @moduledoc """
  Size: 2x2
  Walls: 1

  +---+---+
  |   |   |
  +---+---+
  | W |   |
  +---+---+
  """

  use Game.Board,
    cols: 2,
    rows: 2,
    walls: [{0, 0}]
end

defmodule GameBoards.Test3x2 do
  @moduledoc """
  Size: 3x2
  Walls: 0

  +---+---+---+
  |   |   |   |
  +---+---+---+
  |   |   |   |
  +---+---+---+
  """

  use Game.Board,
    cols: 3,
    rows: 2,
    walls: []
end

defmodule GameBoards.Test4x4 do
  @moduledoc """
  Size: 4x4
  Walls: 0
  """

  use Game.Board,
    cols: 4,
    rows: 4,
    walls: []
end

defmodule GameBoards.Test4x4w1 do
  @moduledoc """
  Size: 4x4
  Walls: 1

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

  use Game.Board,
    cols: 4,
    rows: 4,
    walls: [{3, 2}]
end

defmodule GameBoards.Test4x4w2 do
  @moduledoc """
  Size: 4x4
  Walls: 2

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

  use Game.Board,
    cols: 4,
    rows: 4,
    walls: [{1, 2}, {3, 2}]
end
