defmodule YoungvisionPlatformWeb.PageController do
  use YoungvisionPlatformWeb, :controller


  def home(conn, _params) do
    # If user is logged in, redirect to posts
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/posts")
    else
      # Otherwise show the login page
      redirect(conn, to: ~p"/users/log_in")
    end
  end
end
