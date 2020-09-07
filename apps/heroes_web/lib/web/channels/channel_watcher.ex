defmodule Web.ChannelWatcher do
  @moduledoc """
  Watches game channels activity to remove heroes when players disconnect.
  """

  use GenServer, restart: :transient

  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast

  @typep player :: HeroesServer.player_id()
  @typep time :: non_neg_integer()

  ## Client

  @doc """
  Start GenServer under supervision.

  Requires option `:reconnect_timeout`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, time}
  def init(opts) do
    PubSub.subscribe(HeroesWeb.PubSub, "game:lobby")

    {:ok, Keyword.fetch!(opts, :reconnect_timeout)}
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: %{leaves: leaves}}, time) do
    Enum.each(leaves, fn {player, _metas} -> start_timer(player, time) end)

    {:noreply, time}
  end

  @impl true
  def handle_info({:timeout, player}, state) do
    HeroesServer.remove(player)

    {:noreply, state}
  end

  @spec start_timer(player, time) :: reference()
  defp start_timer(id, time) do
    Process.send_after(self(), {:timeout, id}, time)
  end
end
