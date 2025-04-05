defmodule YoungvisionPlatform.Repo.Migrations.AddCoordinatesToEvents do
  use Ecto.Migration
  import Ecto.Query

  def change do
    alter table(:events) do
      add :latitude, :float
      add :longitude, :float
    end

    # Sadly we can't really update the locations here because http requests
    # do not work well during migrations.
  end
end
