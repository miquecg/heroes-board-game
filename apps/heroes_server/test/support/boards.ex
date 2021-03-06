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

  use GameUtils.Board,
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

  use GameUtils.Board,
    cols: 3,
    rows: 2
end

defmodule GameBoards.Test4x3w5 do
  @moduledoc """
  Size: 4x3
  Walls: 5

  +---+---+---+---+
  | W | ⠀ | W | ⠀ |
  +---+---+---+---+
  |   |   |   |   |
  +---+---+---+---+
  | W |   | W | W |
  +---+---+---+---+
  """

  use GameUtils.Board,
    cols: 4,
    rows: 3,
    walls: [{0, 0}, {0, 2}, {2, 0}, {2, 2}, {3, 0}]
end

defmodule GameBoards.Test4x4 do
  @moduledoc """
  Size: 4x4
  Walls: 0
  """

  use GameUtils.Board,
    cols: 4,
    rows: 4
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

  use GameUtils.Board,
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

  use GameUtils.Board,
    cols: 4,
    rows: 4,
    walls: [{1, 2}, {3, 2}]
end
