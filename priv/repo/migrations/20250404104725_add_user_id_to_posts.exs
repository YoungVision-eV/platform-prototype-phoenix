defmodule YoungvisionPlatform.Repo.Migrations.AddUserIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all), null: true
    end

    create index(:posts, [:user_id])
  end
end
