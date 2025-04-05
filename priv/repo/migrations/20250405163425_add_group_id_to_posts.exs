defmodule YoungvisionPlatform.Repo.Migrations.AddGroupIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :group_id, references(:groups, on_delete: :nilify_all)
    end

    create index(:posts, [:group_id])
  end
end
