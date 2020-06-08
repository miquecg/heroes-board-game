defmodule Utils.GameBoards do
  @moduledoc """
  Provide functionality for boards with use macro.
  """

  alias Game.{Board, BoardRange}
  alias GameError.BadSize

  @callback spec :: Board.t()
  @callback tiles :: list(Board.tile())
  @callback attack_range(Board.tile()) :: BoardRange.t()
  @callback play(Board.tile(), Board.moves()) :: Board.tile()

  @doc false
  defmacro __using__(opts) do
    board_spec = %Board{
      cols: get(opts, :cols),
      rows: get(opts, :rows),
      walls: get(opts, :walls)
    }

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

  defp get(opts, :walls) do
    walls = Keyword.get(opts, :walls, [])
    MapSet.new(walls)
  end

  defp get(opts, size) do
    value = Keyword.fetch!(opts, size)

    if is_integer(value) and value > 0 do
      value
    else
      raise BadSize, [{size, Macro.to_string(value)}]
    end
  end
end
