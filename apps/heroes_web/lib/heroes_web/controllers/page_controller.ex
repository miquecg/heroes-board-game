defmodule HeroesWeb.PageController do
  use HeroesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
