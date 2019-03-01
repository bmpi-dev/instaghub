defmodule Instaghub.Ins do
  use GenServer
  alias Ins.Web.API
  require Instaghub.PoolMacro

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def get_feeds(cursor \\ nil) do
    Instaghub.PoolMacro.pool :ins_api_pool, opt: {:get_feeds, cursor}
  end

  def get_user_posts(id, cursor \\ nil) do
    Instaghub.PoolMacro.pool :ins_api_pool, opt: {:get_user_posts, {id, cursor}}
  end

  def get_tag_posts(tag_name, cursor \\ nil) do
    Instaghub.PoolMacro.pool :ins_api_pool, opt: {:get_tag_posts, {tag_name, cursor}}
  end

  def get_post_comment(shortcode) do
    Instaghub.PoolMacro.pool :ins_api_pool, opt: {:get_post_comment, shortcode}
  end

  def get_user_profile(user) do
    Instaghub.PoolMacro.pool :ins_api_pool, opt: {:get_user_profile, user}
  end

  def search_tags_users(query_str) do
    Instaghub.PoolMacro.pool :ins_api_pool, opt: {:search_tags_users, query_str}
  end

  # Server (callbacks)

  @impl true
  def init(config) do
      {:ok, config}
  end

  @impl true
  def handle_call(cmd, _from, stat) do
    res = case cmd do
            {:get_feeds, cursor} -> API.get_feeds(cursor)
            {:get_user_posts, {id, cursor}} -> API.get_user_posts(id, cursor)
            {:get_tag_posts, {tag_name, cursor}} -> API.get_tag_posts(tag_name, cursor)
            {:get_post_comment, shortcode} -> API.get_post_comment(shortcode)
            {:get_user_profile, user} -> API.get_user_profile(user)
            {:search_tags_users, query_str} -> API.search_tags_users(query_str)
          end
    {:reply, res, stat}
  end

end
