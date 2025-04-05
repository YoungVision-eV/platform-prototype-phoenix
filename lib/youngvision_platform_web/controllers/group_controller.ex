defmodule YoungvisionPlatformWeb.GroupController do
  use YoungvisionPlatformWeb, :controller

  alias YoungvisionPlatform.Community
  alias YoungvisionPlatform.Community.Group
  alias YoungvisionPlatform.Accounts

  def index(conn, _params) do
    groups = Community.list_groups()
    render(conn, :index, groups: groups)
  end

  def new(conn, _params) do
    changeset = Community.change_group(%Group{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    case Community.create_group(group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    group = Community.get_group_with_posts!(id)
    is_member = if current_user, do: Community.is_user_in_group?(current_user, group), else: false
    
    render(conn, :show, group: group, is_member: is_member)
  end

  def edit(conn, %{"id" => id}) do
    group = Community.get_group!(id)
    changeset = Community.change_group(group)
    render(conn, :edit, group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Community.get_group!(id)

    case Community.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Community.get_group!(id)
    {:ok, _group} = Community.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: ~p"/groups")
  end

  def join(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    group = Community.get_group!(id)

    case Community.add_user_to_group(user, group) do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "You have joined the group.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to join the group.")
        |> redirect(to: ~p"/groups/#{group}")
    end
  end

  def leave(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    group = Community.get_group!(id)

    case Community.remove_user_from_group(user, group) do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "You have left the group.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "You are not a member of this group.")
        |> redirect(to: ~p"/groups/#{group}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to leave the group.")
        |> redirect(to: ~p"/groups/#{group}")
    end
  end
end
