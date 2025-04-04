defmodule YoungvisionPlatform.Accounts.ProfilePicture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profile_pictures" do
    field :path, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile_picture, attrs) do
    profile_picture
    |> cast(attrs, [:path])
    |> validate_required([:path])
  end
end
