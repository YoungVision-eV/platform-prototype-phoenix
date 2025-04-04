defmodule YoungvisionPlatform.Repo.Migrations.AddLocationToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :location, :string
      add :latitude, :float
      add :longitude, :float
    end
  end
end
