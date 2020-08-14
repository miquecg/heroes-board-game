defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  describe "Player position is tracked on game:board topic." do
    setup context do
      [socket: subscribe_and_join!(context.socket, @topics.board)]
    end

    test "When joining presence_state is pushed and presence_diff broadcasted",
         %{player_id: id} do
      assert_push "presence_state", %{}

      assert_broadcast "presence_diff", %{joins: %{^id => %{metas: metas}}, leaves: %{}}
      assert [%{phx_ref: _, x: 5, y: 3}] = metas
    end

    test "When leaving presence_diff is broadcasted", %{socket: socket, player_id: id} do
      Process.unlink(socket.channel_pid)

      ref = leave(socket)
      assert_reply ref, :ok

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end

    test "When closing socket presence_diff is broadcasted", %{socket: socket, player_id: id} do
      Process.unlink(socket.channel_pid)

      :ok = close(socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end
  end

  test "A player cannot join if the hero is no longer active", context do
    stop_supervised!(Game.Hero)

    assert {:error, %{reason: "join crashed"}} = join(context.socket, @topics.board)
  end

  test "A tracked player cannot join simultaneously on different socket connections", context do
    {:ok, _, _} = join(context.socket, @topics.board)

    assert {:error, %{reason: "unauthorized"}} = join(context.socket, @topics.board)
  end
end
