defmodule YoungvisionPlatform.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias YoungvisionPlatform.Repo
  alias Phoenix.PubSub

  alias YoungvisionPlatform.Messaging.Message

  @pubsub YoungvisionPlatform.PubSub

  # PubSub topic for user messages
  def user_topic(user_id), do: "user:#{user_id}:messages"

  # Subscribe to messages for a user
  def subscribe_to_messages(user_id) do
    PubSub.subscribe(@pubsub, user_topic(user_id))
  end

  # Broadcast a new message to the recipient
  def broadcast_message(message) do
    PubSub.broadcast(
      @pubsub,
      user_topic(message.recipient_id),
      {:new_message, message}
    )
  end

  @doc """
  Returns the list of messages for a conversation between two users.
  Orders messages by insertion time (newest last).
  """
  def list_conversation(user1_id, user2_id) do
    Message
    |> where(
      [m],
      (m.sender_id == ^user1_id and m.recipient_id == ^user2_id) or
        (m.sender_id == ^user2_id and m.recipient_id == ^user1_id)
    )
    |> order_by([m], asc: m.inserted_at)
    |> preload([:sender, :recipient])
    |> Repo.all()
  end

  @doc """
  Returns the list of conversations for a user.
  A conversation is represented by the most recent message between the user and another user.
  """
  def list_conversations(user_id) do
    # Get all users the current user has exchanged messages with
    conversation_partners =
      Message
      |> where([m], m.sender_id == ^user_id or m.recipient_id == ^user_id)
      |> select(
        [m],
        fragment(
          "CASE WHEN ? = ? THEN ? ELSE ? END",
          m.sender_id,
          ^user_id,
          m.recipient_id,
          m.sender_id
        )
      )
      |> distinct(true)
      |> Repo.all()

    # For each conversation partner, get the most recent message
    Enum.map(conversation_partners, fn partner_id ->
      Message
      |> where(
        [m],
        (m.sender_id == ^user_id and m.recipient_id == ^partner_id) or
          (m.sender_id == ^partner_id and m.recipient_id == ^user_id)
      )
      |> order_by([m], desc: m.inserted_at)
      |> limit(1)
      |> preload([:sender, :recipient])
      |> Repo.one()
    end)
    |> Enum.sort_by(fn message -> message.inserted_at end, {:desc, DateTime})
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.
  """
  def get_message!(id), do: Repo.get!(Message, id) |> Repo.preload([:sender, :recipient])

  @doc """
  Creates a message.
  """
  def create_message(sender, recipient, attrs \\ %{}) do
    attrs_with_users =
      attrs
      |> Map.put("sender_id", sender.id)
      |> Map.put("recipient_id", recipient.id)

    %Message{}
    |> Message.changeset(attrs_with_users)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, [:sender, :recipient])
        # Broadcast the new message to the recipient
        broadcast_message(message)
        {:ok, message}

      error ->
        error
    end
  end

  @doc """
  Updates a message.
  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Marks a message as read.
  """
  def mark_as_read(%Message{} = message) do
    update_message(message, %{read_at: DateTime.utc_now()})
  end

  @doc """
  Marks all messages from a sender to a recipient as read.
  """
  def mark_all_as_read(sender_id, recipient_id) do
    now = DateTime.utc_now()

    Message
    |> where(
      [m],
      m.sender_id == ^sender_id and m.recipient_id == ^recipient_id and is_nil(m.read_at)
    )
    |> Repo.update_all(set: [read_at: now, updated_at: now])
  end

  @doc """
  Returns the count of unread messages for a user.
  """
  def count_unread_messages(user_id) do
    Message
    |> where([m], m.recipient_id == ^user_id and is_nil(m.read_at))
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Deletes a message.
  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end
end
