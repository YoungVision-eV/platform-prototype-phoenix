defmodule YoungvisionPlatformWeb.PostController do
  use YoungvisionPlatformWeb, :controller

  alias YoungvisionPlatform.Community
  alias YoungvisionPlatform.Community.Post

  def index(conn, _params) do
    posts = Community.list_posts()
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Community.Post.changeset(%Post{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Community.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Community.get_post!(id)
    render(conn, :show, post: post)
  end
end
