defmodule GameError.BadSize do
  alias __MODULE__

  defexception [:message]

  @impl true
  def exception(info) do
    {:ok, size} = Keyword.fetch(info, :size)
    {:ok, value} = Keyword.fetch(info, :value)

    msg = "Invalid board dimensions, got #{size}: #{inspect(value)}"
    %BadSize{message: msg}
  end
end
