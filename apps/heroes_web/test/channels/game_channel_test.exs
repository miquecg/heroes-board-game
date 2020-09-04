defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  setup :dummy_hero

  describe "Player position is tracked on game:board topic." do
    setup context do
      [socket: subscribe_and_join!(context.socket, @topics.board)]
    end

    setup %{socket: socket} do
      [player_id: socket.assigns.player_id]
    end

    test "When joining channel presence_state is pushed and presence_diff broadcasted",
         %{player_id: id} do
      assert_push "presence_state", %{}

      assert_broadcast "presence_diff", %{joins: %{^id => %{metas: metas}}, leaves: %{}}
      assert [%{phx_ref: _, x: 5, y: 3}] = metas
    end

    test "When leaving channel presence_diff is broadcasted", %{player_id: id} = context do
      leave_channel(context.socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end

    test "When closing socket presence_diff is broadcasted", %{player_id: id} = context do
      close_socket(context.socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end
  end

  describe "Player online presence is tracked on game:lobby topic." do
    setup context do
      @endpoint.subscribe(@topics.lobby)
      {:ok, _, socket} = join(context.socket, @topics.board)

      [socket: socket]
    end

    setup %{socket: socket} do
      [player_id: socket.assigns.player_id]
    end

    test "When joining channel presence_diff is broadcasted", %{player_id: id} do
      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{^id => _metas},
          leaves: %{}
        },
        topic: "game:lobby"
      }
    end

    test "When leaving channel presence_diff is broadcasted", %{player_id: id} = context do
      leave_channel(context.socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => _metas}
        },
        topic: "game:lobby"
      }
    end

    test "When closing socket presence_diff is broadcasted", %{player_id: id} = context do
      close_socket(context.socket)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{},
          leaves: %{^id => _metas}
        },
        topic: "game:lobby"
      }
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
