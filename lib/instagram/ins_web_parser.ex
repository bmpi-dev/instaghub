defmodule Ins.Web.Parser do

  def parse_tag(object) do
    struct(Ins.Web.Model.Tag, object)
  end

  def parse_media(object) do
    struct(Ins.Web.Model.Media, object)
  end

  def parse_user(object) do
    struct(Ins.Web.Model.User, object)
  end

  def parse_user_search_result(object) do
    struct(Ins.Web.Model.UserSearchResult, object)
  end

  def parse_comment(object) do
    struct(Ins.Web.Model.Comment, object)
  end

  @doc """
  Parse request parameters for the API.
  """
  def parse_request_params(options, accepted) do
    Enum.filter(options, fn({k,_}) -> Enum.member?(accepted, k) end)
    |> Enum.map(fn({k,v}) -> [to_string(k), to_string(v)] end)
  end
end
