defmodule YoungvisionPlatform.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :read_at, :utc_datetime
      add :sender_id, references(:users, on_delete: :nothing), null: false
      add :recipient_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:recipient_id])
  end
end
