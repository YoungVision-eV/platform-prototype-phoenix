defmodule YoungvisionPlatform.Community.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    # We'll keep author for backward compatibility but make it optional
    field :author, :string

    # Add association to users
    belongs_to :user, YoungvisionPlatform.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :user_id])
    |> validate_required([:title, :content, :user_id])
  end
end
