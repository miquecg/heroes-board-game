defmodule Utils.GameBoards do
  @moduledoc """
  Provide functionality for boards with use macro.
  """

  alias Game.Board
  alias GameError.InvalidSize

  @doc false
  defmacro __using__(opts) do
    board_spec = create(opts)
    tiles = Board.generate(board_spec)

    quote do
      alias Game.Board

      @board_spec unquote(Macro.escape(board_spec))

      def spec, do: @board_spec

      def tiles, do: unquote(tiles)

      def attack_range(tile), do: Board.attack_range(tile, @board_spec)

      def play(tile, move), do: Board.play(tile, move, @board_spec)
    end
  end

  defp create(opts) do
    with {:ok, cols} <- valid_size?(opts, :cols),
         {:ok, rows} <- valid_size?(opts, :rows)
    do
      %Board{
        cols: cols,
        rows: rows,
        walls: Keyword.get(opts, :walls, [])
      }
    end
  end

  defp valid_size?(opts, size) do
    value = Keyword.fetch!(opts, size)

    if is_integer(value) and value > 0 do
      {:ok, value}
    else
      raise InvalidSize, [{size, Macro.to_string(value)}]
    end
  end
end
