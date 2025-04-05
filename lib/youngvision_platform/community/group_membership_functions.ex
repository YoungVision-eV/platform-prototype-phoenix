defmodule YoungvisionPlatform.Community.GroupMembershipFunctions do
  @moduledoc """
  Functions for managing group memberships.
  """

  import Ecto.Query, warn: false
  alias YoungvisionPlatform.Repo
  alias YoungvisionPlatform.Community.GroupMembership
  alias YoungvisionPlatform.Community.Group
  alias YoungvisionPlatform.Accounts.User

  @doc """
  Returns the list of group memberships.

  ## Examples

      iex> list_group_memberships()
      [%GroupMembership{}, ...]

  """
  def list_group_memberships do
    Repo.all(GroupMembership)
    |> Repo.preload([:user, :group])
  end

  @doc """
  Returns the list of group memberships for a specific group.

  ## Examples

      iex> list_group_memberships_by_group(group)
      [%GroupMembership{}, ...]

  """
  def list_group_memberships_by_group(%Group{} = group) do
    Repo.all(
      from gm in GroupMembership,
        where: gm.group_id == ^group.id,
        preload: [:user, :group]
    )
  end

  @doc """
  Returns the list of group memberships for a specific user.

  ## Examples

      iex> list_group_memberships_by_user(user)
      [%GroupMembership{}, ...]

  """
  def list_group_memberships_by_user(%User{} = user) do
    Repo.all(
      from gm in GroupMembership,
        where: gm.user_id == ^user.id,
        preload: [:user, :group]
    )
  end

  @doc """
  Gets a single group membership.

  Raises `Ecto.NoResultsError` if the GroupMembership does not exist.

  ## Examples

      iex> get_group_membership!(123)
      %GroupMembership{}

      iex> get_group_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_membership!(id) do
    Repo.get!(GroupMembership, id)
    |> Repo.preload([:user, :group])
  end

  @doc """
  Creates a group membership.

  ## Examples

      iex> create_group_membership(%{field: value})
      {:ok, %GroupMembership{}}

      iex> create_group_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_membership(attrs \\ %{}) do
    %GroupMembership{}
    |> GroupMembership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds a user to a group.

  ## Examples

      iex> add_user_to_group(user, group)
      {:ok, %GroupMembership{}}

      iex> add_user_to_group(user, group)
      {:error, %Ecto.Changeset{}}

  """
  def add_user_to_group(%User{} = user, %Group{} = group) do
    attrs = %{
      user_id: user.id,
      group_id: group.id
    }

    create_group_membership(attrs)
  end

  @doc """
  Removes a user from a group.

  ## Examples

      iex> remove_user_from_group(user, group)
      {:ok, %GroupMembership{}}

      iex> remove_user_from_group(user, group)
      {:error, :not_found}

  """
  def remove_user_from_group(%User{} = user, %Group{} = group) do
    case Repo.one(
           from gm in GroupMembership,
             where: gm.user_id == ^user.id and gm.group_id == ^group.id
         ) do
      nil -> {:error, :not_found}
      membership -> Repo.delete(membership)
    end
  end

  @doc """
  Checks if a user is a member of a group.

  ## Examples

      iex> is_user_in_group?(user, group)
      true

      iex> is_user_in_group?(user, group)
      false

  """
  def is_user_in_group?(%User{} = user, %Group{} = group) do
    Repo.exists?(
      from gm in GroupMembership,
        where: gm.user_id == ^user.id and gm.group_id == ^group.id
    )
  end

  @doc """
  Deletes a group membership.

  ## Examples

      iex> delete_group_membership(group_membership)
      {:ok, %GroupMembership{}}

      iex> delete_group_membership(group_membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_membership(%GroupMembership{} = group_membership) do
    Repo.delete(group_membership)
  end
end
