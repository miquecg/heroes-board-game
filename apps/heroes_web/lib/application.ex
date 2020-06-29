defmodule HeroesWeb.Application do
  @moduledoc false

  use Application

  @app :heroes_web

  @impl true
  def start(_type, _args) do
    mod = get_board()
    player_start = Application.fetch_env!(@app, :player_start)

    children = [
      {Phoenix.PubSub, name: HeroesWeb.PubSub},
      {HeroesServer, board_mod: mod, player_start: player_start},
      {HeroesWeb.Endpoint, board: mod.spec()}
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
    HeroesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
