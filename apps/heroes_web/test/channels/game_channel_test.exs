defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase, async: true

  alias Game.HeroServer

  setup :start_hero

  describe "Presence on game:board topic" do
    setup context do
      socket = subscribe_and_join!(context.socket, @topics.board)

      [socket: socket, player_id: socket.assigns.player_id]
    end

    test "when joining channel", %{player_id: id} do
      assert_push "presence_state", %{}

      assert_broadcast "presence_diff", %{joins: %{^id => %{metas: metas}}, leaves: %{}}
      assert [%{phx_ref: _, x: 5, y: 3}] = metas
    end

    test "when leaving channel", %{player_id: id} = context do
      leave_channel(context.socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end

    test "when closing socket", %{player_id: id} = context do
      close_socket(context.socket)

      assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    end
  end

  describe "Presence on game:lobby topic" do
    setup context do
      @endpoint.subscribe(@topics.lobby)
      {:ok, _, socket} = join(context.socket, @topics.board)

      [socket: socket, player_id: socket.assigns.player_id]
    end

    test "when joining channel", %{player_id: id} do
      assert_receive %Phoenix.Socket.Broadcast{
        event: "presence_diff",
        payload: %{
          joins: %{^id => _metas},
          leaves: %{}
        },
        topic: "game:lobby"
      }
    end

    test "when leaving channel", %{player_id: id} = context do
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

    test "when closing socket", %{player_id: id} = context do
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

  test "Join crashes if the hero is no longer active", context do
    stop_supervised!(HeroServer)

    assert {:error, %{reason: "join crashed"}} = join(context.socket, @topics.board)
  end

  test "Join unauthorized on a second connection for the same player", %{socket: socket} do
    {:ok, _, _} = join(socket, @topics.board)

    assert {:error, %{reason: "unauthorized"}} = join(socket, @topics.board)
  end

  defp start_hero(%{test: name, socket: socket}) do
    opts = [
      name: name,
      board: nil,
      tile: {5, 3}
    ]
    start_supervised!({HeroServer, opts})

    assigns = %{
      player_id: Atom.to_string(name),
      hero: name
    }

    [socket: Phoenix.Socket.assign(socket, assigns)]
  end
end
