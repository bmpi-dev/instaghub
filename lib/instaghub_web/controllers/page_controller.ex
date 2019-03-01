defmodule InstaghubWeb.PageController do
  use InstaghubWeb, :controller
  alias Ins.Web.API
  alias Instaghub.RedisUtil
  alias InstaghubWeb.Plug.Cache
  require Logger

  def index(conn, _params) do
    cursor = Cache.get_cursor(conn)
    redis_key_md5 = Cache.get_page_key(conn, cursor)
    page = Cache.get_page(conn)
    feeds_with_page =
    if page == nil do
      feeds_with_page = API.get_feeds(cursor)
      feeds_bin   = :erlang.term_to_binary(feeds_with_page)
      RedisUtil.setx(redis_key_md5, feeds_bin)
      Logger.debug "get page with api and store in redis with key #{redis_key_md5}"
      feeds_with_page
    else
      page
    end
    if cursor == nil do
      render(conn, "index.html", posts: feeds_with_page.posts, page_info: feeds_with_page.page_info)
    else
      conn
      |> put_layout(false)
      |> put_view(InstaghubWeb.HtmlView)
      |> render("posts.html", posts: feeds_with_page.posts, page_info: feeds_with_page.page_info)
    end
  end
end
