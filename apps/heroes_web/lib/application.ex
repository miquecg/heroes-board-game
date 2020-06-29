defmodule HeroesWeb.Application do
  @moduledoc false

  use Application

  @app :heroes_web

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: HeroesWeb.PubSub},
      {HeroesServer, board: board(), start_tile: start_tile()},
      HeroesWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: HeroesWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp board do
    board = System.get_env("BOARD", "oblivion")

    board
    |> String.capitalize()
    |> (&("Elixir.GameBoards." <> &1)).()
    |> String.to_existing_atom()
  end

  defp start_tile, do: Application.fetch_env!(@app, :start_tile)

  def config_change(changed, _new, removed) do
    HeroesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
