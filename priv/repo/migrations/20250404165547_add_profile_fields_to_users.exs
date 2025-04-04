defmodule YoungvisionPlatform.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :pronouns, :string
      add :bio, :text
    end
  end
end
