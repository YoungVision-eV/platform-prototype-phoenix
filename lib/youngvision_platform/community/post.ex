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
    # Add association to groups
    belongs_to :group, YoungvisionPlatform.Community.Group
    # Add association to comments
    has_many :comments, YoungvisionPlatform.Community.Comment
    # Add association to reactions
    has_many :reactions, YoungvisionPlatform.Community.Reaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :user_id, :group_id])
    |> validate_required([:title, :content, :user_id])
  end
end
