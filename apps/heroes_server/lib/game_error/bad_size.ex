defmodule GameError.BadSize do
  alias __MODULE__

  defexception [:message]

  @impl true
  def exception([{size, value}]) when is_atom(size) and is_binary(value) do
    msg = "Invalid board dimensions, got #{size}: #{value}"
    %BadSize{message: msg}
  end
end
