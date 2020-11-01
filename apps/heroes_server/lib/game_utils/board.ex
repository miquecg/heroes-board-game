defmodule GameUtils.Board do
  @moduledoc """
  Provide functionality for creating boards with use macro.
  """

  alias Game.Board

  @callback x_axis :: Board.axis()
  @callback y_axis :: Board.axis()
  @callback walls :: MapSet.t(Board.wall())
  @callback tiles :: list(Board.tile())
  @callback play(Board.tile(), Board.move()) :: Board.tile()

  @doc false
  defmacro __using__(opts) do
    board = Board.new(opts)
    tiles = Board.generate(board)

    quote bind_quoted: [board: Macro.escape(board), tiles: tiles] do
      @behaviour GameUtils.Board

      alias Game.Board

      @board board

      for key when key != :__struct__ <- Map.keys(@board) do
        @impl true
        def unquote(key)(), do: @board.unquote(key)
      end

      @impl true
      def tiles, do: unquote(tiles)

      @impl true
      def play(tile, move), do: Board.play(@board, tile, move)
    end
  end
end
