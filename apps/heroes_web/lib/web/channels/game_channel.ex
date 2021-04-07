defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Game.Board
  alias Phoenix.Socket
  alias Web.Presence

  @typep game_update :: {:ok, ref :: binary()} | {:error, reason :: term()}

  @impl true
  def join("game:board", _msg, %{assigns: %{game: game, player: player}} = socket) do
    case game.position(player) do
      {_x, _y} = position ->
        send(self(), {:after_join, position})
        hero = %{hero: hero_id()}
        {:ok, hero, assign(socket, hero)}

      {} ->
        {:error, %{reason: "game over"}}
    end
  end

  @impl true
  def handle_info({:after_join, position}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    with {:ok, _} <- authorize_player(socket),
         {:ok, _} <- track_hero(socket, position) do
      no_reply(socket)
    else
      {:error, _} -> shutdown(socket)
    end
  end

  @impl true
  def handle_in(
        "game:board",
        %{"cmd" => input},
        %{assigns: %{game: game, player: player}} = socket
      ) do
    with {:ok, command} <- validate_command(input),
         {:ok, result} <- game.play(player, command),
         :ok <- update_board(socket, result) do
      no_reply(socket)
    end
  end

  @impl true
  def terminate({:shutdown, reason}, %{assigns: %{game: game, player: player}})
      when reason in [:left, :closed] do
    game.remove(player)
    {:ok, _} = Presence.update(self(), "game:lobby", player, %{logout: true})
  end

  @impl true
  def terminate(_, _), do: :ok

  @spec hero_id :: binary()
  defp hero_id do
    bytes = :crypto.strong_rand_bytes(8)
    Base.encode16(bytes, case: :lower)
  end

  @spec authorize_player(Socket.t()) :: game_update
  defp authorize_player(%{assigns: %{player: id}}) do
    case Presence.get_by_key("game:lobby", id) do
      [] -> Presence.track(self(), "game:lobby", id, %{})
      _ -> {:error, :max_connections}
    end
  end

  @spec track_hero(Socket.t(), Board.tile()) :: game_update
  defp track_hero(%{assigns: %{hero: id}} = socket, {x, y}) do
    Presence.track(socket, id, %{x: x, y: y})
  end

  @spec update_board(Socket.t(), Board.tile() | :released) :: :ok
  defp update_board(%{assigns: %{hero: id}} = socket, {x, y}) do
    {:ok, _} = Presence.update(socket, id, %{x: x, y: y})
    :ok
  end

  defp update_board(_, :released), do: :ok

  @spec validate_command(String.t()) :: {:ok, Board.move()}
  defp validate_command("↑"), do: {:ok, :up}
  defp validate_command("↓"), do: {:ok, :down}
  defp validate_command("←"), do: {:ok, :left}
  defp validate_command("→"), do: {:ok, :right}
  defp validate_command("⚔"), do: {:ok, :attack}

  defp no_reply(socket), do: {:noreply, socket}
  defp shutdown(socket), do: {:stop, :shutdown, socket}
end
