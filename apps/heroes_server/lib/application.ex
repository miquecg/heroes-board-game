defmodule HeroesServer do
  @moduledoc """
  This module is the entry point to start playing the game.
  """

  @app :heroes_server

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Heroes.Supervisor]
    DynamicSupervisor.start_link(opts)
  end

  def join do
    board = board()
    tile = choose_tile(board)

    opts = [board: board, tile: tile]
    {:ok, pid} = DynamicSupervisor.start_child(Heroes.Supervisor, {Hero, opts})

    {pid, tile}
  end

  defp choose_tile(board) do
    tiles = board.tiles()
    tile_chooser().(tiles)
  end

  defp board, do: Application.fetch_env!(@app, :board)

  defp tile_chooser do
    case Application.get_env(@app, :start_tile, :randomized) do
      :randomized -> &Enum.random/1
      :first -> &Kernel.hd/1
    end
  end
end
