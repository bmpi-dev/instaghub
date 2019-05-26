defmodule Instaghub.Utils do
  alias Phoenix.HTML
  require Logger

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

  def check_ua_type(conn) do
    ua = conn |> Plug.Conn.get_req_header("user-agent") |> Enum.at(0)
    cond do
      is_googlebot(ua) ->
        :googlebot
      is_otherbot(ua) ->
        :otherbot
      true ->
        :human
    end
  end

  defp is_googlebot(ua) do
    case ua do
      nil -> false
      _ -> ua |> String.downcase |> (fn s -> String.contains?(s, "googlebot") end).()
    end
  end

  defp is_otherbot(ua) do
    other_bot = ["grapeshot", "ia_archiver", "slurp", "teoma", "yandex", "yeti", "baiduspider", "bot"]
    case ua do
      nil -> true
      _ -> ua |> String.downcase |> (fn s -> !String.contains?(s, "googlebot") && Enum.any?(Enum.map(other_bot, fn x -> String.contains?(s, x) end)) end).()
    end
  end
end
