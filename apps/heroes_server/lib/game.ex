defmodule Game do
  @moduledoc """
  Aliases of public types defined in other modules.
  """

  @type tile :: Game.Board.tile()

  @type wall :: Game.Board.wall()

  @type moves :: Game.Board.moves()

  @type board :: Game.Board.t()

  @type board_range :: Game.BoardRange.t()

  @type player :: Game.Player.t()
end
