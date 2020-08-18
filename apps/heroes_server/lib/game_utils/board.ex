defmodule GameUtils.Board do
  @moduledoc """
  Provide functionality for creating boards with use macro.
  """

  alias Game.Board

  @callback x_axis :: Board.axis()
  @callback y_axis :: Board.axis()
  @callback walls :: MapSet.t(Board.wall())
  @callback tiles :: list(Board.tile())
  @callback play(Board.tile(), Board.moves()) :: Board.tile()

  @doc false
  defmacro __using__(opts) do
    board = Board.new(opts)
    tiles = Board.generate(board)

    quote do
      @behaviour GameUtils.Board

      alias Game.Board

      @board unquote(Macro.escape(board))

      @impl true
      def x_axis, do: @board.x_axis

      @impl true
      def y_axis, do: @board.y_axis

      @impl true
      def walls, do: @board.walls

      @impl true
      def tiles, do: unquote(tiles)

      @impl true
      def play(tile, move), do: Board.play(@board, tile, move)
    end
  end
end
