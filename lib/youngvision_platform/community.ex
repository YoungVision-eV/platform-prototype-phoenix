defmodule YoungvisionPlatform.Community do
  @moduledoc """
  The Community context.
  """

  import Ecto.Query, warn: false
  alias YoungvisionPlatform.Repo
  alias Phoenix.PubSub

  alias YoungvisionPlatform.Community.Post
  alias YoungvisionPlatform.Community.Comment
  alias YoungvisionPlatform.Community.Reaction

  @pubsub YoungvisionPlatform.PubSub

  # PubSub topic for posts
  def posts_topic, do: "posts"

  # Subscribe to post updates
  def subscribe_to_posts do
    PubSub.subscribe(@pubsub, posts_topic())
  end

  # Broadcast when a post is created
  def broadcast_post_created(post) do
    PubSub.broadcast(@pubsub, posts_topic(), {:post_created, post})
  end

  # Broadcast when a comment is added
  def broadcast_comment_added(comment) do
    PubSub.broadcast(@pubsub, posts_topic(), {:comment_added, comment})
  end

  # Broadcast when a reaction is added
  def broadcast_reaction_added(reaction) do
    PubSub.broadcast(@pubsub, posts_topic(), {:reaction_added, reaction})
  end

  @doc """
  Returns the list of posts with user information.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(
      from p in Post,
        order_by: [desc: p.inserted_at],
        preload: [:user, comments: [:user], reactions: [:user]]
    )
  end

  @doc """
  Returns the list of posts by a specific user.

  ## Examples

      iex> list_posts_by_user(user)
      [%Post{}, ...]

  """
  def list_posts_by_user(user) do
    Repo.all(
      from p in Post,
        where: p.user_id == ^user.id,
        order_by: [desc: p.inserted_at],
        preload: [:user, comments: [:user], reactions: [:user]]
    )
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
  def get_post!(id),
    do: Repo.get!(Post, id) |> Repo.preload([:user, comments: [:user], reactions: [:user]])

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
    |> case do
      {:ok, post} ->
        post = Repo.preload(post, [:user])
        broadcast_post_created(post)
        {:ok, post}

      error ->
        error
    end
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
    |> case do
      {:ok, comment} ->
        comment = Repo.preload(comment, [:user, :post])
        broadcast_comment_added(comment)
        {:ok, comment}

      error ->
        error
    end
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

  # Event-related functions
  alias YoungvisionPlatform.Community.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(from e in Event, order_by: [asc: e.start_time], preload: [:user])
  end

  @doc """
  Returns the list of events within a date range.

  ## Examples

      iex> list_events_in_range(~U[2025-04-01 00:00:00Z], ~U[2025-04-30 23:59:59Z])
      [%Event{}, ...]

  """
  def list_events_in_range(start_date, end_date) do
    Repo.all(
      from e in Event,
        where: e.start_time >= ^start_date and e.start_time <= ^end_date,
        order_by: [asc: e.start_time],
        preload: [:user]
    )
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id) do
    event = Repo.get!(Event, id) |> Repo.preload(:user)
    IO.inspect(event, label: "Event in get_event!")
    IO.inspect(event.user, label: "User in get_event!")
    event
  end

  @doc """
  Creates an event associated with a user.

  ## Examples

      iex> create_event(user, %{field: value})
      {:ok, %Event{}}

      iex> create_event(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(user, attrs \\ %{}) do
    IO.inspect(user, label: "User in create_event")
    attrs_with_user = Map.put(attrs, "user_id", user.id)
    IO.inspect(attrs_with_user, label: "Attrs with user_id")

    # Create the event with the user directly associated
    %Event{user: user}
    |> Event.changeset(attrs_with_user)
    |> Repo.insert()
    |> case do
      {:ok, event} ->
        # Force a reload with the user preloaded to ensure it's available
        preloaded = Repo.get!(Event, event.id) |> Repo.preload(:user)
        IO.inspect(preloaded, label: "Preloaded event")
        IO.inspect(preloaded.user, label: "Preloaded event user")
        {:ok, preloaded}

      error ->
        IO.inspect(error, label: "Error in create_event")
        error
    end
  end

  @doc """
  Updates an event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, :user)}
      error -> error
    end
  end

  @doc """
  Deletes an event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
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
    |> case do
      {:ok, reaction} ->
        reaction = Repo.preload(reaction, [:user, :post])
        broadcast_reaction_added(reaction)
        {:ok, reaction}

      error ->
        error
    end
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
          {:ok, reaction} ->
            # Reaction already broadcast by create_reaction
            {:ok, :created, reaction}

          {:error, changeset} ->
            {:error, changeset}
        end

      reaction ->
        case delete_reaction(reaction) do
          {:ok, _deleted_reaction} ->
            # Broadcast the reaction removal
            PubSub.broadcast(
              @pubsub,
              posts_topic(),
              {:reaction_removed, %{post_id: post.id, emoji: emoji, user_id: user.id}}
            )

            {:ok, :deleted}

          {:error, changeset} ->
            {:error, changeset}
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

  # Group-related functions
  defdelegate list_groups, to: YoungvisionPlatform.Community.GroupFunctions
  defdelegate get_group!(id), to: YoungvisionPlatform.Community.GroupFunctions
  defdelegate get_group_with_members!(id), to: YoungvisionPlatform.Community.GroupFunctions
  defdelegate create_group(attrs), to: YoungvisionPlatform.Community.GroupFunctions
  defdelegate update_group(group, attrs), to: YoungvisionPlatform.Community.GroupFunctions
  defdelegate delete_group(group), to: YoungvisionPlatform.Community.GroupFunctions
  defdelegate change_group(group, attrs \\ %{}), to: YoungvisionPlatform.Community.GroupFunctions

  # Group membership-related functions
  defdelegate list_group_memberships, to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate list_group_memberships_by_group(group), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate list_group_memberships_by_user(user), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate get_group_membership!(id), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate create_group_membership(attrs), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate add_user_to_group(user, group), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate remove_user_from_group(user, group), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate is_user_in_group?(user, group), to: YoungvisionPlatform.Community.GroupMembershipFunctions
  defdelegate delete_group_membership(group_membership), to: YoungvisionPlatform.Community.GroupMembershipFunctions
end
