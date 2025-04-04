defmodule YoungvisionPlatform.Community.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :description, :string
    field :title, :string
    field :location, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    belongs_to :user, YoungvisionPlatform.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :start_time, :end_time, :location, :user_id])
    |> validate_required([:title, :description, :start_time, :end_time, :location, :user_id])
  end
end
