defmodule HeroesServer do
  @moduledoc """
  The entrypoint to start playing the game.
  """

  @app :heroes_server

  def join do
    board = board()
    tile = choose_tile(board)

    opts = [board: board, tile: tile]
    {:ok, pid} = DynamicSupervisor.start_child(Game.HeroSupervisor, {Game.Hero, opts})

    {pid, tile}
  end

  defp board, do: Application.fetch_env!(@app, :board)

  defp choose_tile(board) do
    tiles = board.tiles()
    tile_chooser().(tiles)
  end

  defp tile_chooser do
    case Application.get_env(@app, :start_tile, :randomized) do
      :randomized -> &Enum.random/1
      :first -> &Kernel.hd/1
    end
  end
end
