defmodule YoungvisionPlatformWeb.HealthController do
  use YoungvisionPlatformWeb, :controller

  alias YoungvisionPlatform.Repo
  import Ecto.Query

  def index(conn, _params) do
    # Check database connection
    database_online = Repo.one(from _ in fragment("SELECT TRUE"), select: true)

    if database_online do
      conn
      |> put_status(:ok)
      |> text("ok")
    else
      conn
      |> put_status(:service_unavailable)
      |> text("database unavailable")
    end
  end
end
