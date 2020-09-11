defmodule Web.ErrorViewTest do
  use HeroesWeb.ConnCase, async: true

  import Phoenix.View

  alias Web.ErrorView

  test "404.html" do
    assert render_to_string(ErrorView, "404.html", []) == "Not Found"
  end

  test "500.html" do
    assert render_to_string(ErrorView, "500.html", []) == "Internal Server Error"
  end
end
