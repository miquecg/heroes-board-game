defmodule Web.StatusController do
  use HeroesWeb, :controller

  def ping(conn, _params), do: send_resp(conn, 204, "")
end
