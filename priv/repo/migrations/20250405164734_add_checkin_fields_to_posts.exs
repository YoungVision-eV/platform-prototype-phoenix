defmodule YoungvisionPlatform.Repo.Migrations.AddCheckinFieldsToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :post_type, :string, default: "regular"
      add :checkin_type, :string
      add :max_participants, :integer
      add :participants, {:array, :map}, default: []
      add :is_full, :boolean, default: false
    end

    create index(:posts, [:post_type])
  end
end
