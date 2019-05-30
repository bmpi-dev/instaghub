defmodule InstaghubWeb.Plug.QPS do
  require Logger
  alias Instaghub.Utils

  @max_qps_googlebot 2
  @max_qps_human 5

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _params) do
    ua_type = conn
    |> Utils.check_ua_type
    Instaghub.Bucket.increase_req(ua_type)
    if is_need_check_qps(conn.request_path) do
      conn |> check_qps(ua_type)
    else
      conn
    end
  end

  defp is_need_check_qps(req_path) do
    if String.contains?(req_path, "/tag/") || String.contains?(req_path, "/user/") do
      true
    else
      false
    end
  end

  def check_qps(conn, ua_type) do
    case ua_type do
      :googlebot -> googlebot_action(conn, ua_type)
      :otherbot -> otherbot_action(conn, ua_type)
      _ -> human_action(conn, ua_type)
    end
  end

  defp googlebot_action(conn, ua_type) do
    qps = Instaghub.Bucket.get_req(ua_type)
    Logger.info "req is google bot, current req count is #{qps}"
    if qps > @max_qps_googlebot do
      Logger.info "beyond max googlebot qps and we will halt all request"
      conn
      |> Plug.Conn.put_status(:too_many_requests)
      |> Phoenix.Controller.put_view(InstaghubWeb.ErrorView)
      |> Phoenix.Controller.render("429.html", %{})
      |> before_halt(ua_type)
      |> Plug.Conn.halt
    else
      conn
    end
  end

  defp otherbot_action(conn, ua_type) do
    Logger.info "if other bot we will halt all request"
    conn
    |> Plug.Conn.put_status(:too_many_requests)
    |> Phoenix.Controller.put_view(InstaghubWeb.ErrorView)
    |> Phoenix.Controller.render("429.html", %{})
    |> before_halt(ua_type)
    |> Plug.Conn.halt
  end

  defp human_action(conn, ua_type) do
    qps = Instaghub.Bucket.get_req(ua_type)
    Logger.info "req is human, current req count is #{qps}"
    if qps > @max_qps_human do
      Logger.info "beyond max human qps and we will redirect to index"
      conn
      |> Phoenix.Controller.redirect(to: "/")
      |> before_halt(ua_type)
      |> Plug.Conn.halt
    else
      conn
    end
  end

  defp before_halt(conn, ua_type) do
    Logger.debug "before halt we will decrease req #{ua_type}"
    Instaghub.Bucket.decrease_req(ua_type)
    conn
  end

end
