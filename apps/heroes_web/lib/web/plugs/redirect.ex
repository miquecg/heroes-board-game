defmodule Web.Plugs.Redirect do
  @moduledoc """
  Simple redirect Plug.
  """

  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Phoenix.Controller.redirect(opts)
    |> Plug.Conn.halt()
  end
end
