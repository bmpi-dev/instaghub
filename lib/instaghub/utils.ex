defmodule Instaghub.Utils do
  def md5_base64(str) do
    :crypto.hash(:md5, str)
    |> Base.encode64()
  end
end
