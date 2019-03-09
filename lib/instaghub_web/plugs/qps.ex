defmodule InstaghubWeb.Plug.QPS do
  require Logger

  @max_qps 44

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _params) do
    conn
    |> check_qps
  end

  def check_qps(conn) do
    qps = Instaghub.Bucket.get_req
    if qps > @max_qps do
      Logger.info "beyond max qps and we will halt all request"
      conn
      |> Plug.Conn.put_status(:too_many_requests)
      |> Phoenix.Controller.put_view(InstaghubWeb.ErrorView)
      |> Phoenix.Controller.render("429.html", %{})
      |> Plug.Conn.halt
    else
      Instaghub.Bucket.increase_req
      conn
    end
  end

end
