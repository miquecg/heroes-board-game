defmodule Web.Application do
  @moduledoc false

  use Application

  @app :heroes_web
  @one_minute_ms 60_000

  @impl true
  def start(_type, _args) do
    board = get_board()

    children = [
      {Phoenix.PubSub, name: Web.PubSub},
      Web.Presence,
      {Web.ChannelWatcher, watcher_opts()},
      {Game, game_opts(board)},
      {Web.Endpoint, board: board}
    ]

    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec get_board :: module()
  defp get_board do
    board = System.get_env("BOARD", "oblivion")

    board
    |> String.capitalize()
    |> (&("Elixir.GameBoards." <> &1)).()
    |> String.to_existing_atom()
  end

  @spec game_opts(module()) :: keyword()
  defp game_opts(board) do
    [
      board: board,
      player_spawn: Application.get_env(@app, :player_spawn, :randomized)
    ]
  end

  @spec watcher_opts :: keyword()
  defp watcher_opts do
    [
      reconnect_timeout: Application.get_env(@app, :reconnect_timeout, @one_minute_ms)
    ]
  end

  @impl true
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
