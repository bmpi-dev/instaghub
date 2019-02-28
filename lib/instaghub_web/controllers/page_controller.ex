defmodule InstaghubWeb.PageController do
  use InstaghubWeb, :controller
  alias Ins.Web.API
  alias Instaghub.RedisUtil
  alias Instaghub.Utils

  def index(conn, params) do
    cursor = Map.get(params, "cursor")
    redis_key = if cursor == nil do
      "index"
    else
      "index" <> cursor
    end
    redis_key_md5 = Utils.md5_base64(redis_key)
    value = RedisUtil.get(redis_key_md5)
    feeds_with_page =
    if value == nil do
      feeds_with_page = API.get_feeds(cursor)
      feeds_bin   = :erlang.term_to_binary(feeds_with_page)
      RedisUtil.setx(redis_key_md5, feeds_bin)
      IO.puts "get page with api and store in redis with key #{redis_key_md5}"
      feeds_with_page
    else
      IO.puts "get page with redis key #{redis_key_md5}"
      :erlang.binary_to_term value
    end
    render(conn, "index.html", posts: feeds_with_page.posts, page_info: feeds_with_page.page_info)
  end
end
