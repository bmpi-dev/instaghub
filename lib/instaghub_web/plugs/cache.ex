defmodule InstaghubWeb.Plug.Cache do
  alias Instaghub.RedisUtil
  alias Instaghub.Utils
  require Logger

  @page_cursor "cursor"
  @page_key :page

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _params) do
    cursor = get_cursor(conn)
    redis_key_md5 = get_page_key(conn, cursor)
    value = RedisUtil.get(redis_key_md5)
    feeds_with_page =
    if value == nil do
      nil
    else
      Logger.debug "get page with redis key #{redis_key_md5}"
      :erlang.binary_to_term value
    end
    Map.put(conn, @page_key, feeds_with_page)
  end

  def get_page(conn) do
    Map.get(conn, @page_key)
  end

  def get_cursor(conn) do
    Map.get(conn.params, @page_cursor)
  end

  def get_page_key(conn, cursor) do
    redis_key = if cursor == nil do
      conn.request_path
    else
      Logger.debug "request_path #{conn.request_path}"
      conn.request_path <> cursor
    end
    Utils.md5_base64(redis_key)
  end
end
