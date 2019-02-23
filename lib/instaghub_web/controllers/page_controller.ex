defmodule InstaghubWeb.PageController do
  use InstaghubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
