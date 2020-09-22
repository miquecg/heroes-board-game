defmodule Web.ChannelWatcherTest do
  use HeroesWeb.ChannelCase

  setup [:join_game, :monitor_hero]

  setup context do
    timeout = Map.get(context, :reconnect, 50)
    start_supervised!({Web.ChannelWatcher, reconnect_timeout: timeout})
    :ok
  end

  test "Remove hero after leaving channel", %{socket: socket, ref: ref} do
    leave_channel(socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 300
  end

  test "Remove hero after closing socket", %{socket: socket, ref: ref} do
    close_socket(socket)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 300
  end

  test "Do not remove hero when player reconnects", %{socket: socket, ref: ref} do
    leave_channel(socket)
    {:ok, _, _} = join(socket, @topics.board)

    refute_receive {:DOWN, ^ref, :process, _pid, :normal}, 500
  end

  @tag reconnect: 100
  test "Track different players correctly", %{socket: socket, ref: ref} do
    leave_channel(socket)

    second_player_socket = player_socket()
    {:ok, _, _} = join(second_player_socket, @topics.board)

    assert_receive {:DOWN, ^ref, :process, _pid, :normal}, 300
  end

  defp player_socket do
    Web.PlayerSocket
    |> socket()
    |> assign_player()
  end

  defp join_game(context) do
    {:ok, _, socket} =
      context.socket
      |> assign_player()
      |> join(@topics.board)

    [socket: socket]
  end

  defp monitor_hero(%{socket: socket}) do
    ref =
      socket.assigns.player_id
      |> (&GenServer.whereis({:via, Registry, {Registry.Heroes, &1}})).()
      |> Process.monitor()

    [ref: ref]
  end

  defp assign_player(socket) do
    assigns = %{
      player_id: Game.join(GameBoards.Test4x4, fn _ -> {0, 0} end),
      game: Game
    }

    Phoenix.Socket.assign(socket, assigns)
  end
end
