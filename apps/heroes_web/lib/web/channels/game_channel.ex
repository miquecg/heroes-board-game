defmodule Web.GameChannel do
  @moduledoc """
  Channel for game actions and player presence updates.
  """

  use HeroesWeb, :channel

  alias Game.Board
  alias GameError.BadCommand

  alias Phoenix.Socket
  alias Web.Presence

  @impl true
  def join("game:board", _msg, %{assigns: %{game: game, player: player}} = socket) do
    case game.position(player) do
      {_x, _y} = position ->
        send(self(), {:after_join, position})
        hero = %{hero: hero_id()}
        {:ok, hero, assign(socket, hero)}

      {} ->
        {:error, response(:unauthorized)}
    end
  end

  @impl true
  def handle_info({:after_join, position}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    with :ok <- check_active_connections(socket),
         :ok <- track_hero(socket, position),
         :ok <- subscribe_to_game(socket) do
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
    else
      {:error, :dead} -> no_reply(socket)
      {:error, reason} -> error_reply(reason, socket)
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

  @spec check_active_connections(Socket.t()) :: :ok | {:error, :max_connections}
  defp check_active_connections(%{assigns: %{player: id}}) do
    case Presence.get_by_key("game:lobby", id) do
      [] ->
        {:ok, _} = Presence.track(self(), "game:lobby", id, %{})
        :ok

      _ ->
        {:error, :max_connections}
    end
  end

  @spec track_hero(Socket.t(), Board.tile()) :: :ok
  defp track_hero(%{assigns: %{hero: id}} = socket, {x, y}) do
    {:ok, _} = Presence.track(socket, id, %{x: x, y: y})
    :ok
  end

  @spec subscribe_to_game(Socket.t()) :: :ok
  defp subscribe_to_game(%{assigns: %{game: game, player: player, hero: hero}} = socket) do
    game.subscribe(player, fn ->
      {:ok, _} = Presence.update(socket, hero, &Map.put(&1, :state, "dead"))
      push(socket, "game_over", %{})
    end)
  end

  @spec update_board(Socket.t(), Board.tile() | :released) :: :ok
  defp update_board(%{assigns: %{hero: id}} = socket, {x, y}) do
    {:ok, _} = Presence.update(socket, id, %{x: x, y: y})
    :ok
  end

  defp update_board(_, :released), do: :ok

  @spec validate_command(String.t()) :: {:ok, Board.move()} | {:error, BadCommand.t()}
  defp validate_command("↑"), do: {:ok, :up}
  defp validate_command("↓"), do: {:ok, :down}
  defp validate_command("←"), do: {:ok, :left}
  defp validate_command("→"), do: {:ok, :right}
  defp validate_command("⚔"), do: {:ok, :attack}
  defp validate_command(_), do: {:error, %BadCommand{}}

  defp no_reply(socket), do: {:noreply, socket}
  defp error_reply(reason, socket), do: {:reply, {:error, response(reason)}, socket}
  defp shutdown(socket), do: {:stop, :shutdown, socket}

  defp response(:unauthorized) do
    %{
      reason: "unauthorized",
      message: "Authorization invalid"
    }
  end

  defp response(%BadCommand{message: msg}) do
    %{
      reason: "bad_command",
      message: msg
    }
  end
end
