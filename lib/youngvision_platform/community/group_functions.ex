defmodule YoungvisionPlatform.Community.GroupFunctions do
  @moduledoc """
  Functions for managing groups.
  """

  import Ecto.Query, warn: false
  alias YoungvisionPlatform.Repo
  alias YoungvisionPlatform.Community.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Gets a single group with its members preloaded.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group_with_members!(123)
      %Group{users: [%User{}, ...]}

  """
  def get_group_with_members!(id) do
    Repo.get!(Group, id)
    |> Repo.preload(:users)
  end

  @doc """
  Gets a single group with its members and posts preloaded.
  If current_user is provided, it will only include posts that the user has access to.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group_with_posts!(123)
      %Group{users: [%User{}, ...], posts: [%Post{}, ...]}

      iex> get_group_with_posts!(123, current_user)
      %Group{users: [%User{}, ...], posts: [%Post{}, ...]}

  """
  def get_group_with_posts!(id, current_user) do
    group = Repo.get!(Group, id) |> Repo.preload(:users)

    posts = list_group_posts(group, current_user)

    %{group | posts: posts}
  end

  @doc """
  Returns the list of posts for a specific group.
  If current_user is provided, it will check if the user is a member of the group.
  If the user is not a member, it will return an empty list.

  ## Examples
      iex> list_group_posts(group, current_user)
      [%Post{}, ...]

  """
  def list_group_posts(%Group{} = group, current_user) do
    import Ecto.Query

    if is_member?(current_user.id, group.id) do
      Repo.all(
        from p in YoungvisionPlatform.Community.Post,
          where: p.group_id == ^group.id,
          order_by: [desc: p.inserted_at],
          preload: [:user, :group, comments: [:user], reactions: [:user]]
      )
    else
      []
    end
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Checks if a user is a member of a group.

  ## Examples

      iex> is_member?(user_id, group_id)
      true

      iex> is_member?(user_id, group_id)
      false

  """
  def is_member?(user_id, group_id) do
    import Ecto.Query

    query =
      from gm in YoungvisionPlatform.Community.GroupMembership,
        where: gm.user_id == ^user_id and gm.group_id == ^group_id,
        select: count(gm.id)

    Repo.one(query) > 0
  end
end
