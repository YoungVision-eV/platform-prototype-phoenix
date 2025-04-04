defmodule YoungvisionPlatform.Repo do
  use Ecto.Repo,
    otp_app: :youngvision_platform,
    adapter: Ecto.Adapters.Postgres
end
