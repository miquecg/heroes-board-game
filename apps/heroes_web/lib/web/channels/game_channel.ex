defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Phoenix.Socket
  alias Web.Presence

  @impl true
  def join("game:lobby", _message, socket) do
    if authorized?(socket) do
      send(self(), {:after_join, player_position(socket)})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({:after_join, {x, y}}, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.player_id, %{x: x, y: y})
    monitor_hero(socket)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, socket) do
    {:stop, :hero_down, socket}
  end

  @spec authorized?(Socket.t()) :: boolean()
  defp authorized?(socket) do
    case Presence.get_by_key("game:lobby", socket.assigns.player_id) do
      [] -> true
      %{metas: _} -> false
    end
  end

  @spec player_position(Socket.t()) :: Game.Board.tile()
  defp player_position(socket) do
    hero = hero_name(socket)
    Game.Hero.position(hero)
  end

  @spec monitor_hero(Socket.t()) :: reference()
  defp monitor_hero(socket) do
    hero = hero_name(socket)

    hero
    |> GenServer.whereis()
    |> Process.monitor()
  end

  @spec hero_name(Socket.t()) :: GenServer.name()
  defp hero_name(socket), do: HeroesServer.hero_name(socket.assigns.player_id)
end
