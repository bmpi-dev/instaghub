defmodule Ins.Web.Parser do
  use Timex

  def parse_tag(object) do
    case object do
      nil -> nil
      tag -> struct(Ins.Web.Model.Tag, tag)
    end
  end

  def parse_media(object) do
    media = struct(Ins.Web.Model.Media, object)
    parse_media_caption(media)
    |> parse_media_preview_like
    |> parse_media_liked_by
    |> parse_media_comment
    |> parse_media_owner
    |> parse_media_sidecar
    |> parse_media_timestamp
  end

  defp parse_media_caption(media) do
    Map.update(media, :edge_media_to_caption, media.edge_media_to_caption, fn(s) -> s.edges |> Enum.reduce("", fn(x, acc) -> acc <> "\n" <> x.node.text end) |> String.trim("\n") end)
  end

  defp parse_media_preview_like(media) do
    if media.edge_media_preview_like != nil do
      Map.update(media, :edge_media_preview_like, media.edge_media_preview_like, fn(s) -> s.count end)
    else
      media
    end
  end

  defp parse_media_liked_by(media) do
    if media.edge_liked_by != nil do
      Map.update(media, :edge_liked_by, media.edge_liked_by, fn(s) -> s.count end)
    else
      media
    end
  end

  defp parse_media_comment(media) do
    if media.edge_media_to_comment != nil do
      Map.update(media, :edge_media_to_comment, media.edge_media_to_comment, fn(s) ->
        if Map.has_key?(s, :edges) do
          %{count: s.count, edges: s.edges |> Enum.map(&parse_comment(&1.node))}
        else
          s
        end
      end)
    else
      media
    end
  end

  defp parse_media_owner(media) do
    if media.owner != nil do
      Map.update(media, :owner, media.owner, fn(s) -> parse_user(s) end)
    else
      media
    end
  end

  defp parse_media_sidecar(media) do
    if media.edge_sidecar_to_children != nil do
      Map.update(media, :edge_sidecar_to_children, media.edge_sidecar_to_children, fn(s) ->
        s.edges |> Enum.map(&struct(Ins.Web.Model.Media, &1.node))
      end)
    else
      media
    end
  end

  defp parse_media_timestamp(media) do
    if media.taken_at_timestamp != nil do
      Map.update(media, :taken_at_timestamp, media.taken_at_timestamp, fn(s) ->
        Timex.from_now(DateTime.from_unix!(s))
      end)
    else
      media
    end
  end

  def parse_user(object) do
    user = struct(Ins.Web.Model.User, object)
    user
    |> parse_user_edge_follow
    |> parse_user_edge_followed_by
    parse_pk_to_id(user, object)
  end

  defp parse_user_edge_follow(user) do
    if user.edge_follow != nil do
      Map.update(user, :edge_follow, user.edge_follow, fn(s) -> s.count end)
    else
      user
    end
  end

  defp parse_user_edge_followed_by(user) do
    if user.edge_followed_by != nil do
      Map.update(user, :edge_followed_by, user.edge_followed_by, fn(s) -> s.count end)
    else
      user
    end
  end

  defp parse_pk_to_id(user, object) do
    if Map.has_key?(object, :pk) && object.pk != nil do
      Map.update(user, :id, object.pk, fn(_) -> object.pk end)
    else
      user
    end
  end

  def parse_search_result(object) do
    searchs = struct(Ins.Web.Model.SearchResult, object)
    searchs
    |> parse_search_users
    |> parse_search_tags
  end

  defp parse_search_users(object) do
    Map.update(object, :users, object.users, fn(s) ->
      s |> Enum.map(&parse_user(&1.user))
    end)
  end

  defp parse_search_tags(object) do
    Map.update(object, :hashtags, object.hashtags, fn(s) ->
      s |> Enum.map(&parse_tag(&1.hashtag))
    end)
  end

  def parse_comment(object) do
    comment = struct(Ins.Web.Model.Comment, object)
    comment
    |> parse_comment_owner
    |> parse_comment_timestamp
  end

  defp parse_comment_owner(comment) do
    if comment.owner != nil do
      user = parse_user(comment.owner)
      Map.update(comment, :owner, user, fn(s) -> s end)
    else
      comment
    end
  end

  defp parse_comment_timestamp(comment) do
    if comment.created_at != nil do
      Map.update(comment, :created_at, comment.created_at, fn(s) ->
        Timex.from_now(DateTime.from_unix!(s))
      end)
    else
      comment
    end
  end

  @doc """
  Parse request parameters for the API.
  """
  def parse_request_params(options, accepted) do
    Enum.filter(options, fn({k,_}) -> Enum.member?(accepted, k) end)
    |> Enum.map(fn({k,v}) -> [to_string(k), to_string(v)] end)
  end
end
