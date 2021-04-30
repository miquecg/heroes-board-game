defmodule Web.GameChannel do
  @moduledoc """
  Process game actions coming from WebSocket and updates player presence.
  """

  use HeroesWeb, :channel

  require Logger

  alias Game.Board
  alias GameError.BadCommand

  alias Phoenix.Socket
  alias Web.Presence

  @impl true
  def join("game:board", _msg, %{assigns: %{game: game} = assigns} = socket) do
    case game.position(assigns.player) do
      {_x, _y} = position ->
        send(self(), {:after_join, position})
        hero = %{hero: hero_id()}
        {:ok, hero, assign(socket, hero)}

      {} ->
        {:error, response(:unauthorized)}
    end
  end

  @impl true
  def handle_info({:after_join, position}, %{assigns: %{game: game} = assigns} = socket) do
    push(socket, "presence_state", Presence.list(socket))

    with :ok <- check_active_connections(socket),
         :ok <- track_hero(socket, position),
         :ok <- game.subscribe(assigns.player, self()) do
      no_reply(socket)
    else
      {:error, :max_connections} = reason -> stop(reason, socket)
    end
  end

  @impl true
  def handle_info(:game_over, socket), do: game_over(socket)

  @impl true
  def handle_info({:timeout, :game_over}, socket), do: stop(:game_over, socket)

  @impl true
  def handle_info(:timeout, socket) do
    push(socket, "game_over", %{})
    stop(:timeout, socket)
  end

  @impl true
  def handle_in("game:board", %{"cmd" => input}, %{assigns: %{game: game} = assigns} = socket) do
    with {:ok, command} <- validate_command(input),
         {:ok, result} <- game.play(assigns.player, command),
         :ok <- update_board(socket, result) do
      no_reply(socket)
    else
      {:error, :dead} -> game_over(socket)
      {:error, _} = reason -> stop(reason, socket)
    end
  end

  @impl true
  def terminate({:shutdown, reason}, %{assigns: %{game: game} = assigns}) do
    game.remove(assigns.player)
    {:ok, _} = Presence.update(self(), "game:lobby", assigns.player, %{logout: true})
    Logger.info("Channel terminated with reason #{reason}")
  end

  @impl true
  def terminate(_, _), do: :ok

  @spec hero_id :: binary()
  defp hero_id do
    bytes = :crypto.strong_rand_bytes(8)
    Base.encode16(bytes, case: :lower)
  end

  @spec check_active_connections(Socket.t()) :: :ok | {:error, :max_connections}
  defp check_active_connections(%{assigns: assigns}) do
    case Presence.get_by_key("game:lobby", assigns.player) do
      [] ->
        {:ok, _} = Presence.track(self(), "game:lobby", assigns.player, %{})
        :ok

      _ ->
        {:error, :max_connections}
    end
  end

  @spec track_hero(Socket.t(), Board.tile()) :: :ok
  defp track_hero(%{assigns: assigns} = socket, {x, y}) do
    {:ok, _} = Presence.track(socket, assigns.hero, %{x: x, y: y})
    :ok
  end

  @spec update_board(Socket.t(), Board.tile() | :released) :: :ok
  defp update_board(%{assigns: assigns} = socket, {x, y}) do
    {:ok, _} = Presence.update(socket, assigns.hero, %{x: x, y: y})
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

  defp game_over(%{assigns: %{hero: id} = assigns} = socket) do
    {:ok, _} = Presence.update(socket, id, &Map.put(&1, :state, "dead"))
    push(socket, "game_over", %{})

    Process.send_after(self(), {:timeout, :game_over}, 5_000)

    no_reply(%{socket | assigns: Map.delete(assigns, :hero)})
  end

  defp game_over(socket), do: no_reply(socket)

  defp no_reply(socket), do: {:noreply, socket, 60_000}

  defp stop({_, _} = reason, socket), do: {:stop, reason, socket}
  defp stop(reason, socket), do: {:stop, {:shutdown, reason}, socket}

  defp response(:unauthorized) do
    %{
      reason: "unauthorized",
      message: "Authorization invalid"
    }
  end
end
