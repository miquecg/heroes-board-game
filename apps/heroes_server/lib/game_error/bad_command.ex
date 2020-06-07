defmodule GameError.BadCommand do
  defexception message: "Invalid control command for Hero"
end

defmodule GameError.InvalidSize do
  defexception [:message]

  @impl true
  def exception([{size, value}]) when is_atom(size) and is_binary(value) do
    msg = "Invalid board dimensions, got #{size}: #{value}"
    %GameError.InvalidSize{message: msg}
  end
end
