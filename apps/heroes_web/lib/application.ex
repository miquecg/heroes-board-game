defmodule HeroesWeb.Application do
  @moduledoc false

  use Application

  @app :heroes_web

  @impl true
  def start(_type, _args) do
    board = get_board()

    server_opts = [
      board: board,
      player_spawn: Application.fetch_env!(@app, :player_spawn)
    ]

    children = [
      {Phoenix.PubSub, name: HeroesWeb.PubSub},
      Web.Presence,
      {HeroesServer, server_opts},
      {Web.Endpoint, board: board}
    ]

    opts = [strategy: :one_for_one, name: HeroesWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec get_board() :: module()
  defp get_board do
    board = System.get_env("BOARD", "oblivion")

    board
    |> String.capitalize()
    |> (&("Elixir.GameBoards." <> &1)).()
    |> String.to_existing_atom()
  end

  @impl true
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
