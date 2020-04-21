defmodule HeroesServer do
  @moduledoc """
  This module is the entry point to start playing the game.
  """

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Heroes.Supervisor]
    DynamicSupervisor.start_link(opts)
  end

  def join() do
    board = Application.fetch_env!(:heroes_server, :board)
    tile = start_position(board)
    {:ok, pid} = DynamicSupervisor.start_child(Heroes.Supervisor, Hero)

    {pid, tile}
  end

  defp start_position(board) do
    tiles = board.tiles()
    Enum.random(tiles)
  end
end
