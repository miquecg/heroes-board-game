defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  import HeroesServer, only: [hero_name: 1]

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

    {:noreply, socket}
  end

  @spec authorized?(Socket.t()) :: boolean()
  defp authorized?(socket) do
    case Presence.get_by_key("game:lobby", socket.assigns.player_id) do
      [] -> true
      %{metas: _} -> false
    end
  end

  @spec player_position(Socket.t()) :: Game.tile()
  defp player_position(socket) do
    socket.assigns.player_id
    |> hero_name()
    |> Game.Hero.position()
  end
end
