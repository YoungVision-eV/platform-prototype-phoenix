defmodule YoungvisionPlatform.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :emoji, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reactions, [:user_id])
    create index(:reactions, [:post_id])
    # Create a unique index to ensure a user can only react once with each emoji to a post
    create unique_index(:reactions, [:user_id, :post_id, :emoji])
  end
end
