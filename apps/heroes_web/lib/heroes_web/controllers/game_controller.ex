defmodule HeroesWeb.GameController do
  use HeroesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", board: GameBoards.Oblivion.spec())
  end
end
