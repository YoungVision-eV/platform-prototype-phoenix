defmodule YoungvisionPlatform.Messaging.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :read_at, :utc_datetime
    
    belongs_to :sender, YoungvisionPlatform.Accounts.User
    belongs_to :recipient, YoungvisionPlatform.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :read_at, :sender_id, :recipient_id])
    |> validate_required([:content, :sender_id, :recipient_id])
  end
end
