defmodule YoungvisionPlatform.Repo.Migrations.CreateProfilePictures do
  use Ecto.Migration

  def change do
    create table(:profile_pictures) do
      add :path, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:profile_pictures, [:user_id])
  end
end
