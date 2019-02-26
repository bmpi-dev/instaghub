defmodule InstaghubWeb.PageController do
  use InstaghubWeb, :controller
  alias Ins.Web.API

  def index(conn, _params) do
    feeds = API.get_feeds
    render(conn, "index.html", posts: feeds)
  end
end
