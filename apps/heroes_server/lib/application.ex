defmodule HeroesServer do
  @moduledoc """
  This application keeps each hero status and position on the board.
  It's also an API for clients to interact with them.
  """

  use Application

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Heroes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
