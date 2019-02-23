defmodule Instaghub.Repo do
  use Ecto.Repo,
    otp_app: :instaghub,
    adapter: Ecto.Adapters.Postgres
end
