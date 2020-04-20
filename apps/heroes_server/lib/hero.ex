defmodule Hero do
  use GenServer

  # Client

  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  # Server (callbacks)

  @impl true
  def init([]) do
    {:ok, []}
  end
end
