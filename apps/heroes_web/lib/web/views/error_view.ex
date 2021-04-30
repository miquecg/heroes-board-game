defmodule Web.ErrorView do
  use HeroesWeb, :view

  def render("503.html", _assigns), do: "No more players allowed. Try again later."

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
