defmodule YoungvisionPlatform.Community.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    
    belongs_to :user, YoungvisionPlatform.Accounts.User
    belongs_to :post, YoungvisionPlatform.Community.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :user_id, :post_id])
    |> validate_required([:content, :user_id, :post_id])
    |> validate_length(:content, min: 1, max: 1000)
  end
end
