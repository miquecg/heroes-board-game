defmodule GameError.BadCommand do
  @type t :: %__MODULE__{}

  defexception message: "Invalid control command for Hero"
end
