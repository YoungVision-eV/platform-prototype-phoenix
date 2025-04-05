defmodule YoungvisionPlatform.Community.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    # We'll keep author for backward compatibility but make it optional
    field :author, :string
    
    # Check-in fields
    field :post_type, :string, default: "regular"
    field :checkin_type, :string
    field :max_participants, :integer
    field :participants, {:array, :map}, default: []
    field :is_full, :boolean, default: false

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
    |> cast(attrs, [:title, :content, :user_id, :group_id, :post_type, :checkin_type, :max_participants, :participants, :is_full])
    |> validate_required([:title, :content, :user_id])
    |> validate_checkin_fields()
  end

  defp validate_checkin_fields(changeset) do
    case get_field(changeset, :post_type) do
      "checkin" ->
        changeset
        |> validate_required([:checkin_type, :max_participants])
        |> validate_inclusion(:checkin_type, ["duade", "triade"])
        |> validate_number(:max_participants, greater_than: 0)
      _ ->
        changeset
    end
  end
end
