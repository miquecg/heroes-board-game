defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Phoenix.Socket
  alias Web.Presence

  @impl true
  def join("game:lobby", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    server = hero_name(socket)
    {x, y} = Game.Hero.position(server)

    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.player_id, %{x: x, y: y})

    {:noreply, socket}
  end

  @spec hero_name(Socket.t()) :: {:via, module(), term()}
  defp hero_name(socket) do
    {:via, Registry, {HeroesServer.Registry, socket.assigns.player_id}}
  end
end
