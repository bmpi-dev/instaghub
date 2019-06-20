defmodule Ins.Web.API do
  require Logger
  alias Instaghub.RedisUtil

  @base_url "https://www.instagram.com"
  @graphql_url_part "/graphql/query/"
  @search_url_part "/web/search/topsearch/"
  @feed_hash "cd34b0d013fbcb063a2252a398da6cb4"
  @user_hash "f2405b236d85e8296cf30347c9f08c2a"
  @tag_hash "f92f56d47dc7a55b606908374b43a314"
  @post_hash "477b65a610463740ccdb83135b2014db"

  @csrf "csrf"
  @rhx_gis "rhx_gis"

  defp log_err(err, func, msg) do
    Logger.error "error log info begin [#{DateTime.to_string(DateTime.utc_now)}] ===>"
    func |> IO.inspect
    msg |> IO.inspect
    err |> IO.inspect
    Logger.error "error log info end ===>"
    case err do
      Instaghub.Error429 ->
        429
      _ ->
        404
    end
  end

  def get_feeds(cursor \\ nil, menu \\ :sports) do
    if System.get_env("INS_NOT_LOGIN") == "1" do
      get_not_login_feeds(cursor, menu)
    else
      get_login_feeds(cursor, menu)
    end
  end

  defp get_not_login_feeds(cursor, menu) do
    case menu do
      :sports -> get_tag_posts("sports", cursor)
      :women -> get_tag_posts("women", cursor)
      :animal -> get_tag_posts("animal", cursor)
      :game -> get_tag_posts("game", cursor)
      :food -> get_tag_posts("food", cursor)
      :hot -> get_tag_posts("love", cursor)
    end
  end

  defp get_login_feeds(cursor, menu) do
    variables = %{cached_feed_item_ids: [],
                  fetch_media_item_count: 12,
                  fetch_comment_count: 4,
                  fetch_like: 3,
                  has_stories: false,
                  has_threaded_comments: false
                 }
    variables =
    if cursor != nil do
      Map.put(variables, :fetch_media_item_cursor, cursor)

      variables
    end
    params = [["query_hash", @feed_hash], ["variables", Poison.encode!(variables)], ["menu", menu]]
    try do
      res = get(@graphql_url_part, params)
      feeds = res.data.user.edge_web_feed_timeline.edges
      |> Enum.map(&Ins.Web.Parser.parse_media(&1.node))
      %{page_info: res.data.user.edge_web_feed_timeline.page_info, posts: feeds}
    rescue
      err -> log_err(err, :get_feeds, nil)
    end
  end

  def get_user_posts(id, cursor \\ nil) do
    variables = %{id: id,
                  first: 12
                 }
    variables =
    if cursor != nil do
      Map.put(variables, :after, cursor)
    else
      variables
    end
    params = [["query_hash", @user_hash], ["variables", Poison.encode!(variables)]]
    try do
      res = get(@graphql_url_part, params)
      user_posts = res.data.user.edge_owner_to_timeline_media
      posts = user_posts.edges
      |> Enum.map(&Ins.Web.Parser.parse_media(&1.node))
      %{count: user_posts.count, page_info: user_posts.page_info, posts: posts}
    rescue
      err -> log_err(err, :get_user_posts, nil)
    end
  end

  def get_tag_posts(tag_name, cursor \\ nil) do
    variables = %{tag_name: tag_name,
                  show_ranked: false,
                  first: 10
                 }
    variables =
    if cursor != nil do
      Map.put(variables, :after, cursor)
    else
      variables
    end
    params = [["query_hash", @tag_hash], ["variables", Poison.encode!(variables)]]
    try do
      res = get(@graphql_url_part, params)
      tag_posts = Ins.Web.Parser.parse_tag(res.data.hashtag)
      Map.update(tag_posts, :edge_hashtag_to_media, tag_posts.edge_hashtag_to_media, fn(s) ->
        %{count: s.count, page_info: s.page_info, posts: s.edges |> Enum.map(&Ins.Web.Parser.parse_media(&1.node))}
      end)
    rescue
      err -> log_err(err, :get_tag_posts, nil)
    end
  end

  def get_post_comment(shortcode) do
    variables = %{shortcode: shortcode,
                  child_comment_count: 3,
                  fetch_comment_count: 40,
                  parent_comment_count: 24,
                  has_threaded_comments: false
                 }
    params = [["query_hash", @post_hash], ["variables", Poison.encode!(variables)]]
    try do
      res = get(@graphql_url_part, params)
      Ins.Web.Parser.parse_media(res.data.shortcode_media)
    rescue
      err -> log_err(err, :get_post_comment, nil)
    end
  end

  def get_user_profile(user) do
    url_part = "/" <> user <> "/"
    params = [["__a", 1]]
    try do
      res = get(url_part, params)
      user = Ins.Web.Parser.parse_user(res.graphql.user)
      Map.update(user, :edge_owner_to_timeline_media, user.edge_owner_to_timeline_media, fn(s) ->
        %{count: s.count, page_info: s.page_info, posts: s.edges |> Enum.map(&Ins.Web.Parser.parse_media(&1.node))}
      end)
    rescue
      err -> log_err(err, :get_user_profile, nil)
    end
  end

  def search_tags_users(query_str) do
    params = [["query", query_str]]
    try do
      res = get(@search_url_part, params)
      Ins.Web.Parser.parse_search_result(res)
    rescue
      err -> log_err(err, :search_tags_users, nil)
    end
  end

  defp get(url_part, params) do
    headers = generate_header(params)
    Logger.debug "#{inspect headers}"
    [url_part, params]
    |> build_url
    |> HTTPoison.get!(headers)
    |> handle_response
  end

  defp generate_header(params) do
    if System.get_env("INS_NOT_LOGIN") == "1" do
      get_not_login_header(params)
    else
      get_login_header(params)
    end
  end

  defp get_not_login_header(params) do
    v = params |> Enum.at(1)
    variables = if v != nil do
			["variables", var] = v
			var
		else
			nil
		end
    csrf = RedisUtil.get(@csrf)
    rhx_gis = RedisUtil.get(@rhx_gis)
    gis_token = if rhx_gis != nil && variables != nil do
			rhx_gis <> ":" <> variables |> (fn x -> :crypto.hash(:md5, x) end).() |> Base.encode16 |> String.downcase
		else
			nil
		end
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"
    headers = [referer: "https://www.instagram.com/",
			         "user-agent": user_agent]
    headers = if gis_token != nil do
      headers ++ ["x-instagram-gis": gis_token]
    else
      headers
    end
    headers = if csrf != nil do
      headers ++ ["x-csrftoken": csrf]
    else
      headers
    end
    headers
  end

  defp get_login_header(params) do
    session = get_session(params)
    Logger.info "session: #{session}"
    ["Cookie": "sessionid=#{session}"]
  end

  defp get_session(params) do
    case params do
      [["query_hash", @feed_hash], _, ["menu", menu]] -> get_menu_session(menu)
      _ -> get_random_session()
    end
  end

  defp get_menu_session(menu) do
    case menu do
      :sports -> System.get_env("INS_SESSION_ID_SPORTS")
      :women -> System.get_env("INS_SESSION_ID_WOMEN")
      :animal -> System.get_env("INS_SESSION_ID_ANIMAL")
      :game -> System.get_env("INS_SESSION_ID_GAME")
      :food -> System.get_env("INS_SESSION_ID_FOOD")
      :hot -> System.get_env("INS_SESSION_ID_HOT")
      _ -> get_random_session()
    end
  end

  defp get_random_session() do
    ["INS_SESSION_ID_SPORTS", "INS_SESSION_ID_WOMEN", "INS_SESSION_ID_ANIMAL", "INS_SESSION_ID_GAME", "INS_SESSION_ID_FOOD", "INS_SESSION_ID_HOT"]
    |> Enum.random
    |> System.get_env
  end

  defp handle_response(res) do
    case res do
      %HTTPoison.Response{status_code: code, body: body} ->
        case code do
          200 ->
            Poison.decode!(body, keys: :atoms)
          429 ->
            raise(Instaghub.Error429, [code: code, message: "#{body}"])
          _ ->
            raise(Instaghub.Error404, [code: code, message: "#{body}"])
        end
      err -> raise(Instaghub.ErrorOther, [message: err])
    end
  end

  defp build_url([part, params]) do
    params = params |> Enum.reverse
    url = case params do
      [["menu", _] | new_params] -> "#{@base_url}#{part}?#{params_join(new_params |> Enum.reverse)}"
      _ -> "#{@base_url}#{part}?#{params_join(params |> Enum.reverse)}"
    end
    Logger.debug url
    url
  end

  defp params_join([h | t]) do
    [param, value] = h
    params_join(t, "#{param}=#{value}")
  end

  defp params_join([], string) do
    string
  end

  defp params_join([h | []], string) do
    [param, value] = h
    string <> "&#{param}=#{value}"
  end

  defp params_join([h | t], string) do
    [param | value] = h
    params_join(t, string<>"&#{param}=#{value}")
  end

end
