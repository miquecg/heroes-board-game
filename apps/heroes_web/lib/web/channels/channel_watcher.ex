defmodule Web.ChannelWatcher do
  @moduledoc """
  Watches game channels activity to remove heroes when players disconnect.
  """

  use GenServer, restart: :transient

  alias Phoenix.PubSub
  alias Phoenix.Socket.Broadcast

  @typep presences :: Phoenix.Presence.presences()
  @typep diff :: %{joins: presences, leaves: presences}
  @typep timers :: %{optional(binary()) => reference()}
  @typep state :: %{
           game: module(),
           timeout: non_neg_integer(),
           timers: timers
         }

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
  @spec init(keyword()) :: {:ok, state}
  def init(opts) do
    state = %{
      game: Keyword.get(opts, :game, Game),
      timeout: Keyword.fetch!(opts, :reconnect_timeout),
      timers: %{}
    }

    :ok = PubSub.subscribe(Web.PubSub, "game:lobby")

    {:ok, state}
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff", payload: payload}, %{timeout: time} = state) do
    %{joins: joins, leaves: leaves} = remove_updates(payload)

    timers =
      state.timers
      |> cancel_timers(joins)
      |> start_timers(leaves, time)

    {:noreply, %{state | timers: timers}}
  end

  @impl true
  def handle_info({:timeout, id}, %{game: game, timers: timers} = state)
      when is_map_key(timers, id) do
    game.remove(id)
    timers = Map.delete(timers, id)

    {:noreply, %{state | timers: timers}}
  end

  @impl true
  def handle_info({:timeout, _}, state), do: {:noreply, state}

  @spec remove_updates(diff) :: diff
  defp remove_updates(%{joins: joins, leaves: leaves}) do
    {duplicates, joins_deduped} = Map.split(joins, Map.keys(leaves))
    leaves_deduped = Map.drop(leaves, Map.keys(duplicates))

    %{joins: joins_deduped, leaves: leaves_deduped}
  end

  @spec cancel_timers(timers, map()) :: timers
  defp cancel_timers(timers, joins) do
    {cancelled, rest} = Map.split(timers, Map.keys(joins))
    Enum.each(cancelled, fn {_, ref} -> Process.cancel_timer(ref) end)
    rest
  end

  @spec start_timers(timers, map(), non_neg_integer()) :: timers
  defp start_timers(timers, leaves, time) do
    Enum.reduce(leaves, timers, fn
      {_, %{metas: [%{logout: true}]}}, acc ->
        acc

      {id, _}, acc ->
        ref = Process.send_after(self(), {:timeout, id}, time)
        Map.put(acc, id, ref)
    end)
  end
end
