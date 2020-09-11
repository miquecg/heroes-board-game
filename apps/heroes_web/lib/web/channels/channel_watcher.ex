defmodule Web.ChannelWatcher do
  @moduledoc """
  Watches game channels activity to remove heroes when players disconnect.
  """

  use GenServer, restart: :transient

  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast

  @typep time :: non_neg_integer()
  @typep timers :: %{optional(Game.player_id()) => reference()}

  ## Client

  @doc """
  Start GenServer under supervision.

  Requires option `:reconnect_timeout`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, map()}
  def init(opts) do
    PubSub.subscribe(Web.PubSub, "game:lobby")

    state = %{
      time: Keyword.fetch!(opts, :reconnect_timeout),
      refs: %{}
    }

    {:ok, state}
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: payload}, %{time: time} = state) do
    refs =
      state.refs
      |> cancel_timers(payload.joins)
      |> start_timers(payload.leaves, time)

    {:noreply, %{state | refs: refs}}
  end

  @impl true
  def handle_info({:timeout, player}, state) do
    {timer, refs} = Map.pop(state.refs, player)

    if timer do
      Game.remove(player)
    end

    {:noreply, %{state | refs: refs}}
  end

  @spec cancel_timers(timers(), map()) :: timers()
  defp cancel_timers(refs, joins) do
    players = Map.keys(joins)
    Map.drop(refs, players)
  end

  @spec start_timers(timers(), map(), time) :: timers()
  defp start_timers(refs, leaves, time) do
    for {player, _meta} <- leaves, into: refs do
      ref = Process.send_after(self(), {:timeout, player}, time)
      {player, ref}
    end
  end
end
