defmodule Utils.GameBoards do
  @moduledoc """
  Provide functionality for boards with use macro.
  """

  @callback tiles :: list(Game.tile())
  @callback attack_range(Game.tile()) :: Game.board_range()
  @callback play(Game.tile(), Game.moves()) :: Game.tile()

  alias Game.Board

  @doc false
  defmacro __using__(opts) do
    board_spec = Board.new(opts)
    tiles = Board.generate(board_spec)

    quote do
      @behaviour Utils.GameBoards

      alias Game.Board

      @board_spec unquote(Macro.escape(board_spec))

      @impl true
      def tiles, do: unquote(tiles)

      @impl true
      def attack_range(tile), do: Board.attack_range(tile, @board_spec)

      @impl true
      def play(tile, move), do: Board.play(tile, move, @board_spec)
    end
  end
end
