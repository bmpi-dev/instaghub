defmodule Instaghub.Error429 do
  defexception [:code, :message]
end

defmodule Instaghub.Error404 do
  defexception [:code, :message]
end

defmodule Instaghub.ErrorOther do
  defexception [:message]
end
