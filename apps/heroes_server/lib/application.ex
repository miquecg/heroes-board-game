defmodule HeroesServer do
  @moduledoc """
  This module is the entry point to the server.
  All game interaction happens through `Hero` GenServer.
  """

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Heroes.Supervisor]
    DynamicSupervisor.start_link(opts)
  end

  def join() do
    board = Application.fetch_env!(:heroes_server, :board)
    tile = Board.random_tile(board)
    {:ok, pid} = DynamicSupervisor.start_child(Heroes.Supervisor, Hero)

    {pid, tile}
  end
end
