defmodule Ins.Web.API do

  @base_url "https://www.instagram.com"
  @graphql_url_part "/graphql/query/"
  @search_url_part "/web/search/topsearch/"
  @feed_hash "cd34b0d013fbcb063a2252a398da6cb4"
  @user_hash "f2405b236d85e8296cf30347c9f08c2a"
  @tag_hash "f92f56d47dc7a55b606908374b43a314"
  @post_hash "477b65a610463740ccdb83135b2014db"

  def get_feeds(cursor \\ nil) do
    variables = %{fetch_media_item_count: 12,
                  fetch_comment_count: 4,
                  fetch_like: 3,
                  has_stories: false,
                  has_threaded_comments: false
                 }
    variables =
    if cursor != nil do
      Map.put(variables, :fetch_media_item_cursor, cursor)
    else
      variables
    end
    params = [["query_hash", @feed_hash], ["variables", Poison.encode!(variables)]]
    get(@graphql_url_part, params)
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
    get(@graphql_url_part, params)
  end

  def get_tag_posts(tag_name, cursor \\ nil) do
    variables = %{tag_name: tag_name,
                  show_ranked: false,
                  first: 10
                 }
    if cursor != nil do
      Map.put(variables, :after, cursor)
    else
      variables
    end
    params = [["query_hash", @tag_hash], ["variables", Poison.encode!(variables)]]
    get(@graphql_url_part, params)
  end

  def get_post_comment(shortcode) do
    variables = %{shortcode: shortcode,
                  child_comment_count: 3,
                  fetch_comment_count: 40,
                  parent_comment_count: 24,
                  has_threaded_comments: false
                 }
    params = [["query_hash", @post_hash], ["variables", Poison.encode!(variables)]]
    get(@graphql_url_part, params)
  end

  def get_user_profile(user) do
    url_part = "/" <> user <> "/"
    params = [["__a", 1]]
    get(url_part, params)
  end

  def search_tags_users(query_str) do
    params = [["query", query_str]]
    get(@search_url_part, params)
  end

  @doc """
  General HTTP `GET` request function. Takes a url part
  and optionally a token and list of params.
  """
  def get(url_part, params \\ []) do
    session = System.get_env("INSTAGRAM_SESSION_ID")
    headers = ["Cookie": "sessionid=#{session}"]
    [url_part, params]
    |> build_url
    |> HTTPoison.get!(headers)
    |> handle_response
  end

  defp handle_response(%HTTPoison.Response{status_code: code, body: body}) do
    case code do
      200 ->
        Poison.decode!(body, keys: :atoms)
      _ ->
        raise(Instaghub.Error, [code: code, message: "#{body}"])
    end
  end

  defp build_url([part, params]) do
    "#{@base_url}#{part}?#{params_join(params)}"
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
