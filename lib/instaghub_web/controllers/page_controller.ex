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

  def post_comment(conn, %{"shortcode" => shortcode} = _params) do
    redis_key_md5 = Cache.get_page_key(conn, nil)
    page = Cache.get_page(conn)
    feeds_with_page =
    if page == nil do
      feeds_with_page = API.get_post_comment(shortcode)
      feeds_bin   = :erlang.term_to_binary(feeds_with_page)
      RedisUtil.setx(redis_key_md5, feeds_bin)
      Logger.debug "get page with api and store in redis with key #{redis_key_md5}"
      feeds_with_page
    else
      page
    end
    render(conn, "post_comment.html", post: feeds_with_page)
  end

  def user_posts(conn, %{"username" => username} = params) do
    id = Map.get(params, "id")
    cursor = Cache.get_cursor(conn)
    redis_key_md5 = Cache.get_page_key(conn, cursor)
    page = Cache.get_page(conn)
    feeds_with_page =
    if page == nil do
      feeds_with_page = if cursor == nil && id == nil do
        API.get_user_profile(username)
      else
        API.get_user_posts(id, cursor)
      end
      feeds_bin   = :erlang.term_to_binary(feeds_with_page)
      RedisUtil.setx(redis_key_md5, feeds_bin)
      Logger.debug "get page with api and store in redis with key #{redis_key_md5}"
      feeds_with_page
    else
      page
    end
    if cursor == nil do
      render(conn, "user.html", posts: feeds_with_page.edge_owner_to_timeline_media.posts, page_info: feeds_with_page.edge_owner_to_timeline_media.page_info, user: feeds_with_page)
    else
      conn
      |> put_layout(false)
      |> put_view(InstaghubWeb.HtmlView)
      |> render("posts.html", posts: feeds_with_page.posts, page_info: feeds_with_page.page_info)
    end
  end
end
