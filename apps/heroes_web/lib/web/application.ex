defmodule Web.Application do
  @moduledoc false

  use Application

  @app :heroes_web
  @one_minute_ms 60_000

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Web.PubSub},
      Web.Presence,
      {Web.ChannelWatcher, reconnect_timeout: timeout_ms()},
      {Web.Endpoint, board: board(), dice: &Enum.random/1}
    ]

    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec timeout_ms :: non_neg_integer()
  defp timeout_ms, do: Application.get_env(@app, :reconnect_timeout, @one_minute_ms)

  @spec board :: module()
  defp board do
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
