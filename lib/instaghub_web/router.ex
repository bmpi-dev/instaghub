defmodule InstaghubWeb.Router do
  use InstaghubWeb, :router
  alias InstaghubWeb.Plug.Cache
  alias InstaghubWeb.Plug.QPS

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Cache, []
    plug QPS
    plug :dec_qps
  end

  def dec_qps(conn, _opts) do
    Plug.Conn.register_before_send(conn, fn conn ->
      Instaghub.Bucket.decrease_req
      conn
    end)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InstaghubWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/post/:shortcode", PageController, :post_comment
    get "/user/:username", PageController, :user_posts
    get "/tag/:tagname", PageController, :tag_posts
  end

  # Other scopes may use custom stacks.
  # scope "/api", InstaghubWeb do
  #   pipe_through :api
  # end
end
