defmodule Game.BoardSubscriber do
  @moduledoc """
  This module is meant to listen `:unregister` events from `Registry.Game`
  and allows to register callbacks to react on those.
  """

  @typep callback :: (() -> any())
  @typep request :: {:register, callback, pid()}

  use GenServer

  @spec start_link([]) :: GenServer.on_start()
  def start_link([]), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  ## Callbacks

  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  @spec handle_call(request, GenServer.from(), map()) :: {:reply, :ok, map()}
  def handle_call({:register, callback, pid}, _from, state) do
    monitor_ref = Process.monitor(pid)
    state = Map.put(state, pid, {callback, monitor_ref})
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:unregister, Registry.Game, "board", pid}, state) do
    state = execute_callback(state, pid)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {_, state} = Map.pop(state, pid)
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state), do: {:noreply, state}

  @spec execute_callback(map(), pid()) :: map()
  defp execute_callback(state, pid) do
    {_, state} =
      Map.get_and_update(state, pid, fn
        nil ->
          :pop

        {callback, monitor_ref} ->
          {:ok, _} = Task.start(callback)
          Process.demonitor(monitor_ref)
          :pop
      end)

    state
  end
end
