defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Phoenix.Socket
  alias Web.Presence

  @impl true
  def join("game:board", _message, %{assigns: %{player_id: id, game: game}} = socket) do
    if authorized?(socket) do
      {_, _} = position = game.position(id)
      send(self(), {:after_join, position})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({:after_join, {x, y}}, %{assigns: %{player_id: id}} = socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} = Presence.track(socket, id, %{x: x, y: y})
    {:ok, _} = Presence.track(self(), "game:lobby", id, %{})

    {:noreply, socket}
  end

  @spec authorized?(Socket.t()) :: boolean()
  defp authorized?(socket) do
    case Presence.get_by_key(socket, socket.assigns.player_id) do
      [] -> true
      %{metas: _} -> false
    end
  end
end
