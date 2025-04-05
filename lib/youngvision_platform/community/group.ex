defmodule YoungvisionPlatform.Community.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    
    has_many :group_memberships, YoungvisionPlatform.Community.GroupMembership
    has_many :posts, YoungvisionPlatform.Community.Post
    many_to_many :users, YoungvisionPlatform.Accounts.User, join_through: YoungvisionPlatform.Community.GroupMembership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
