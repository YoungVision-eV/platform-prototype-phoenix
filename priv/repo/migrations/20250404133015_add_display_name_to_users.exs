defmodule YoungvisionPlatform.Repo.Migrations.AddDisplayNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :display_name, :string
    end

    # Create an index for display_name to make lookups faster
    create index(:users, [:display_name])
  end
end
