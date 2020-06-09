defmodule Utils.GameBoards do
  @moduledoc """
  Provide functionality for boards with use macro.
  """

  alias Game.{Board, BoardRange}

  @callback spec :: Board.t()
  @callback tiles :: list(Board.tile())
  @callback attack_range(Board.tile()) :: BoardRange.t()
  @callback play(Board.tile(), Board.moves()) :: Board.tile()

  @doc false
  defmacro __using__(opts) do
    board_spec = Board.new(opts)
    tiles = Board.generate(board_spec)

    quote do
      @behaviour Utils.GameBoards

      alias Game.Board

      @board_spec unquote(Macro.escape(board_spec))

      @impl true
      def spec, do: @board_spec

      @impl true
      def tiles, do: unquote(tiles)

      @impl true
      def attack_range(tile), do: Board.attack_range(tile, @board_spec)

      @impl true
      def play(tile, move), do: Board.play(tile, move, @board_spec)
    end
  end
end
