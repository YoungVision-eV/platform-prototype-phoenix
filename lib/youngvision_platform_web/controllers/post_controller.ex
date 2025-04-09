defmodule YoungvisionPlatformWeb.PostController do
  use YoungvisionPlatformWeb, :controller

  import YoungvisionPlatformWeb.UserAuth

  alias YoungvisionPlatform.Community
  alias YoungvisionPlatform.Community.Post
  alias YoungvisionPlatform.Community.Comment

  # Require authentication for all actions in this controller
  plug :require_authenticated_user

  def index(conn, _params) do
    posts = Community.list_posts(conn.assigns.current_user)
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Community.Post.changeset(%Post{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    current_user = conn.assigns.current_user

    case Community.create_post(current_user, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Community.get_post!(id, conn.assigns.current_user)
    comment_changeset = Community.change_comment(%Comment{})
    render(conn, :show, post: post, comment_changeset: comment_changeset)
  end

  def add_comment(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    post = Community.get_post!(post_id, conn.assigns.current_user)
    current_user = conn.assigns.current_user

    case Community.create_comment(current_user, post, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment added successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :show, post: post, comment_changeset: changeset)
    end
  end

  def toggle_reaction(conn, %{"post_id" => post_id, "emoji" => emoji}) do
    post = Community.get_post!(post_id, conn.assigns.current_user)
    current_user = conn.assigns.current_user

    case Community.toggle_reaction(current_user, post, emoji) do
      {:ok, :created, _reaction} ->
        conn
        |> put_flash(:info, "Reaction added.")
        |> redirect(to: ~p"/posts/#{post}")

      {:ok, :deleted} ->
        conn
        |> put_flash(:info, "Reaction removed.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not process reaction.")
        |> redirect(to: ~p"/posts/#{post}")
    end
  end
end
