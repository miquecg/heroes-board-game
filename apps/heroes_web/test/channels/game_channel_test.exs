defmodule Web.GameChannelTest do
  use HeroesWeb.ChannelCase

  alias Web.GameChannel
  alias Web.PlayerSocket, as: Socket

  setup do
    id = HeroesServer.join()
    [assigns: %{player_id: id}]
  end

  setup context do
    {:ok, _, socket} = join_channel(context.assigns)

    %{socket: socket}
  end

  test "Channel pushes presence state to the client when joining" do
    assert_push "presence_state", %{}
  end

  test "Channel broadcasts joins when they happen", context do
    %{player_id: id} = context.assigns

    assert_broadcast "presence_diff", %{joins: %{^id => _metas}, leaves: %{}}
  end

  test "Channel broadcasts leave when a hero is restarted", context do
    flush_messages()

    Process.flag(:trap_exit, true)
    %{player_id: id} = context.assigns
    kill_hero(id)

    assert_broadcast "presence_diff", %{joins: %{}, leaves: %{^id => _metas}}
    assert_receive {:EXIT, _pid, :hero_down}
  end

  test "Channel join crashes with an invalid player_id" do
    assigns = %{player_id: "invalid"}
    assert {:error, %{reason: "join crashed"}} = join_channel(assigns)
  end

  test "Player cannot join channel using different sockets", context do
    assert {:error, %{reason: "unauthorized"}} = join_channel(context.assigns)
  end

  defp join_channel(assigns) do
    Socket
    |> socket(nil, assigns)
    |> subscribe_and_join(GameChannel, "game:lobby")
  end

  def flush_messages(timeout \\ 100) do
    receive do
      %Phoenix.Socket.Message{} ->
        flush_messages()

      %Phoenix.Socket.Broadcast{} ->
        flush_messages()
    after
      timeout -> nil
    end
  end

  defp kill_hero(player_id) do
    player_id
    |> HeroesServer.hero_name()
    |> GenServer.whereis()
    |> Process.exit(:kill)
  end
end
