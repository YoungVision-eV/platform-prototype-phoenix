defmodule YoungvisionPlatform.Community do
  @moduledoc """
  The Community context.
  """

  import Ecto.Query, warn: false
  alias YoungvisionPlatform.Repo

  alias YoungvisionPlatform.Community.Post
  alias YoungvisionPlatform.Community.Comment
  alias YoungvisionPlatform.Community.Reaction

  @doc """
  Returns the list of posts with user information.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(from p in Post, order_by: [desc: p.inserted_at], preload: [:user, :comments, :reactions])
  end

  @doc """
  Gets a single post with user information.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload([:user, comments: [:user], reactions: [:user]])

  @doc """
  Creates a post associated with a user.

  ## Examples

      iex> create_post(user, %{field: value})
      {:ok, %Post{}}

      iex> create_post(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(user, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(Map.put(attrs, "user_id", user.id))
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  # Comment-related functions

  @doc """
  Returns the list of comments for a specific post.

  ## Examples

      iex> list_comments(post_id)
      [%Comment{}, ...]

  """
  def list_comments(post_id) do
    Comment
    |> where([c], c.post_id == ^post_id)
    |> order_by([c], asc: c.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id) |> Repo.preload(:user)

  @doc """
  Creates a comment associated with a user and post.

  ## Examples

      iex> create_comment(user, post, %{field: value})
      {:ok, %Comment{}}

      iex> create_comment(user, post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(user, post, attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(Map.merge(attrs, %{"user_id" => user.id, "post_id" => post.id}))
    |> Repo.insert()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  # Reaction-related functions

  @doc """
  Returns the list of valid emoji reactions.
  """
  def list_valid_emojis do
    Reaction.valid_emojis()
  end

  @doc """
  Returns a map of emoji to their display names.
  """
  def emoji_names do
    Reaction.emoji_names()
  end

  @doc """
  Returns the list of reactions for a specific post.

  ## Examples

      iex> list_reactions(post_id)
      [%Reaction{}, ...]

  """
  def list_reactions(post_id) do
    Reaction
    |> where([r], r.post_id == ^post_id)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a single reaction.

  Raises `Ecto.NoResultsError` if the Reaction does not exist.

  ## Examples

      iex> get_reaction!(123)
      %Reaction{}

      iex> get_reaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reaction!(id), do: Repo.get!(Reaction, id) |> Repo.preload(:user)

  @doc """
  Gets a reaction by user, post, and emoji.

  Returns nil if the reaction does not exist.

  ## Examples

      iex> get_reaction_by_user_post_emoji(user_id, post_id, emoji)
      %Reaction{}

      iex> get_reaction_by_user_post_emoji(user_id, post_id, emoji)
      nil

  """
  def get_reaction_by_user_post_emoji(user_id, post_id, emoji) do
    Reaction
    |> where([r], r.user_id == ^user_id and r.post_id == ^post_id and r.emoji == ^emoji)
    |> Repo.one()
  end

  @doc """
  Creates a reaction associated with a user and post.

  ## Examples

      iex> create_reaction(user, post, %{field: value})
      {:ok, %Reaction{}}

      iex> create_reaction(user, post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reaction(user, post, attrs \\ %{}) do
    %Reaction{}
    |> Reaction.changeset(Map.merge(attrs, %{"user_id" => user.id, "post_id" => post.id}))
    |> Repo.insert()
  end

  @doc """
  Toggles a reaction for a user on a post.
  If the reaction already exists, it is deleted. Otherwise, it is created.

  ## Examples

      iex> toggle_reaction(user, post, emoji)
      {:ok, :created, %Reaction{}}

      iex> toggle_reaction(user, post, emoji)
      {:ok, :deleted}

  """
  def toggle_reaction(user, post, emoji) do
    case get_reaction_by_user_post_emoji(user.id, post.id, emoji) do
      nil ->
        case create_reaction(user, post, %{"emoji" => emoji}) do
          {:ok, reaction} -> {:ok, :created, reaction}
          {:error, changeset} -> {:error, changeset}
        end

      reaction ->
        case delete_reaction(reaction) do
          {:ok, _} -> {:ok, :deleted}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  @doc """
  Deletes a reaction.

  ## Examples

      iex> delete_reaction(reaction)
      {:ok, %Reaction{}}

      iex> delete_reaction(reaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reaction(%Reaction{} = reaction) do
    Repo.delete(reaction)
  end

  @doc """
  Returns a map of reaction counts for a post, grouped by emoji.

  ## Examples

      iex> get_reaction_counts(post_id)
      %{"👌" => 3, "❤️" => 1}

  """
  def get_reaction_counts(post_id) do
    Reaction
    |> where([r], r.post_id == ^post_id)
    |> group_by([r], r.emoji)
    |> select([r], {r.emoji, count(r.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end

  @doc """
  Checks if a user has reacted to a post with a specific emoji.

  ## Examples

      iex> user_has_reacted?(user_id, post_id, emoji)
      true

      iex> user_has_reacted?(user_id, post_id, emoji)
      false

  """
  def user_has_reacted?(user_id, post_id, emoji) do
    not is_nil(get_reaction_by_user_post_emoji(user_id, post_id, emoji))
  end
end
