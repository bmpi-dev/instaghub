defmodule Instaghub.Utils do
  alias Phoenix.HTML

  def md5_base64(str) do
    :crypto.hash(:md5, str)
    |> Base.encode64()
  end

  def parse_link(str) do
    str
    |> String.downcase
    |> parse_user_link
    |> parse_hashtag_link
    |> HTML.raw
  end

  defp parse_user_link(str) do
    str
    |> (fn(x) -> Regex.replace(~r/[@][^\s#@$!?]+/, x, "<a href=\"/user/\\0\">\\0</a>", global: true) end).()
    |> String.replace("/user/@", "/user/")
    |> String.replace(".\">", "\">")
    |> String.replace(")\">", "\">")
    |> String.replace(" \">", "\">")
  end

  defp parse_hashtag_link(str) do
    str
    |> (fn(x) -> Regex.replace(~r/[#][^\s#@$!?]+/, x, "<a href=\"/tag/\\0\">\\0</a>", global: true) end).()
    |> String.replace("/tag/#", "/tag/")
    |> String.replace(".\">", "\">")
    |> String.replace(")\">", "\">")
    |> String.replace(" \">", "\">")
  end
end
