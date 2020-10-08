defmodule Web.ChannelWatcher do
  @moduledoc """
  Watches game channels activity to remove heroes when players disconnect.
  """

  use GenServer, restart: :transient

  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast

  @typep player_id :: GameBehaviour.player_id()

  @typep time :: non_neg_integer()
  @typep timers :: %{optional(player_id) => reference()}

  ## Client

  @doc """
  Start GenServer under supervision.

  Requires option `:reconnect_timeout`.

  A module implementing the game behaviour
  can be passed with option `:game`.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  ## Server (callbacks)

  @impl true
  @spec init(keyword()) :: {:ok, map()}
  def init(opts) do
    state = %{
      game: Keyword.get(opts, :game, Game),
      time: Keyword.fetch!(opts, :reconnect_timeout),
      refs: %{}
    }
    PubSub.subscribe(Web.PubSub, "game:lobby")

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
  def handle_info({:timeout, player}, %{game: game} = state) do
    {timer, refs} = Map.pop(state.refs, player)

    if timer do
      game.remove(player)
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
