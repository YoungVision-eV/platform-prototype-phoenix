defmodule YoungvisionPlatform.Community.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  # Define valid emoji reactions
  @valid_emojis ["👌", "❤️", "🤔", "🙏", "✨"]
  @emoji_names %{
    "👌" => "ok hand",
    "❤️" => "heart",
    "🤔" => "questioning face",
    "🙏" => "pray hands",
    "✨" => "sprinkling stars"
  }

  schema "reactions" do
    field :emoji, :string
    
    belongs_to :user, YoungvisionPlatform.Accounts.User
    belongs_to :post, YoungvisionPlatform.Community.Post

    timestamps(type: :utc_datetime)
  end

  @doc """
  Returns a list of valid emoji reactions.
  """
  def valid_emojis, do: @valid_emojis

  @doc """
  Returns a map of emoji to their display names.
  """
  def emoji_names, do: @emoji_names

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:emoji, :user_id, :post_id])
    |> validate_required([:emoji, :user_id, :post_id])
    |> validate_inclusion(:emoji, @valid_emojis)
    |> unique_constraint([:user_id, :post_id, :emoji])
  end
end
