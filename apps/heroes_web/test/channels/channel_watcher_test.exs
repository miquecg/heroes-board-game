defmodule Web.ChannelWatcherTest do
  use HeroesWeb.ChannelCase

  import Mox

  @game GameMock

  setup do
    opts = [
      game: @game,
      reconnect_timeout: 50
    ]
    {:ok, child} = start_supervised({Web.ChannelWatcher, opts})

    [watcher_pid: child]
  end

  setup context do
    stub(@game, :position, fn _ -> {0, 0} end)
    allow(@game, self(), context.watcher_pid)
    :ok
  end

  setup context do
    {:ok, _, socket} = join(context.socket, @topics.board)

    [socket: socket]
  end

  setup :verify_on_exit!

  test "Remove hero after leaving channel", %{socket: socket} do
    reply = expect_call_remove_once()

    leave_channel(socket)

    assert_receive ^reply, 200
  end

  test "Remove hero after closing socket", %{socket: socket} do
    reply = expect_call_remove_once()

    close_socket(socket)

    assert_receive ^reply, 200
  end

  test "Do not remove hero when player reconnects", %{socket: socket} do
    expect_not_call_remove()

    leave_channel(socket)
    {:ok, _, _} = join(socket, @topics.board)

    :timer.sleep(200)
  end

  test "Track different players correctly", %{socket: socket} do
    {msg, fun} = remove_callback()
    expect(@game, :remove, fn "test_player" = arg -> fun.(arg) end)

    leave_channel(socket)
    {:ok, _, _} =
      "second_player"
      |> player_socket()
      |> join(@topics.board)

    assert_receive ^msg, 200
  end

  defp expect_call_remove_once do
    {msg, fun} = remove_callback()
    expect(@game, :remove, fun)
    msg
  end

  defp expect_not_call_remove, do: expect(@game, :remove, 0, fn _ -> :ok end)

  defp remove_callback do
    parent = self()
    msg = {make_ref(), :done}

    fun = fn _ ->
      send(parent, msg)
      :ok
    end

    {msg, fun}
  end
end
