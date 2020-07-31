defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Phoenix.Socket
  alias Web.Presence

  @impl true
  def join("game:lobby", _message, socket) do
    send(self(), {:after_join, player_position(socket)})
    {:ok, socket}
  end

  @impl true
  def handle_info({:after_join, {x, y}}, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.player_id, %{x: x, y: y})

    {:noreply, socket}
  end

  @spec player_position(Socket.t()) :: Game.tile()
  defp player_position(socket) do
    server = {:via, Registry, {HeroesServer.Registry, socket.assigns.player_id}}
    Game.Hero.position(server)
  end
end
