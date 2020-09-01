defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Game.Hero
  alias Phoenix.Socket
  alias Web.Presence

  @topic "game:board"

  @impl true
  def join(@topic, _message, socket) do
    if authorized?(socket) do
      send(self(), {:after_join, Hero.position(socket.assigns.hero)})
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
    case Presence.get_by_key(@topic, socket.assigns.player_id) do
      [] -> true
      %{metas: _} -> false
    end
  end
end
