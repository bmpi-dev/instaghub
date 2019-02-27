defmodule InstaghubWeb.PageController do
  use InstaghubWeb, :controller
  alias Ins.Web.API

  def index(conn, params) do
    cursor = Map.get(params, "cursor")
    feeds_with_page = API.get_feeds(cursor)
    render(conn, "index.html", posts: feeds_with_page.posts, page_info: feeds_with_page.page_info)
  end
end
