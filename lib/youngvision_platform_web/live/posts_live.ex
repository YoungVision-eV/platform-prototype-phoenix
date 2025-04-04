defmodule YoungvisionPlatformWeb.PostsLive do
  use YoungvisionPlatformWeb, :live_view

  alias YoungvisionPlatform.Community

  @impl true
  def mount(_params, _session, socket) do
    # Check if current_user is in the assigns
    current_user = Map.get(socket.assigns, :current_user)
    
    if current_user do
      # Subscribe to post updates when the LiveView connects
      if connected?(socket) do
        Community.subscribe_to_posts()
      end
      
      # Make sure posts are properly preloaded with all associations
      posts = Community.list_posts()
      
      {:ok, 
        socket
        |> assign(:posts, posts)
        |> assign(:post, nil)
        |> assign(:comment_form, to_form(%{"content" => ""}))
      }
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, 
      socket
      |> apply_action(socket.assigns.live_action, params)
    }
  end
  
  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Community Feed")
  end
  
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
  end
  
  defp apply_action(socket, :show, %{"id" => id}) do
    post = Community.get_post!(id)
    
    socket
    |> assign(:page_title, post.title)
    |> assign(:post, post)
  end

  @impl true
  def handle_event("create-post", %{"post" => post_params}, socket) do
    case Community.create_post(socket.assigns.current_user, post_params) do
      {:ok, post} ->
        {:noreply, 
          socket
          |> put_flash(:info, "Post created successfully")
          |> push_navigate(to: ~p"/posts/#{post.id}")
        }
      
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, 
          socket
          |> put_flash(:error, "Error creating post")
          |> assign(:changeset, changeset)
        }
    end
  end

  @impl true
  def handle_event("add-comment", %{"comment" => comment_params, "post_id" => post_id}, socket) do
    post = Community.get_post!(post_id)
    
    case Community.create_comment(socket.assigns.current_user, post, comment_params) do
      {:ok, _comment} ->
        {:noreply, 
          socket
          |> put_flash(:info, "Comment added successfully")
          |> assign(:comment_form, to_form(%{"content" => ""}))
        }
      
      {:error, _changeset} ->
        {:noreply, 
          socket
          |> put_flash(:error, "Error adding comment")
        }
    end
  end

  @impl true
  def handle_event("add-reaction", %{"post_id" => post_id, "emoji" => emoji}, socket) do
    post = Community.get_post!(post_id)
    
    case Community.toggle_reaction(socket.assigns.current_user, post, emoji) do
      {:ok, _status, _reaction} ->
        {:noreply, socket}
      
      {:ok, :deleted} ->
        {:noreply, socket}
      
      {:error, _changeset} ->
        {:noreply, 
          socket
          |> put_flash(:error, "Error adding reaction")
        }
    end
  end

  # Handle broadcast events
  @impl true
  def handle_info({:post_created, post}, socket) do
    updated_posts = [post | socket.assigns.posts]
    |> Enum.sort_by(fn p -> p.inserted_at end, {:desc, DateTime})
    
    {:noreply, assign(socket, :posts, updated_posts)}
  end

  @impl true
  def handle_info({:comment_added, comment}, socket) do
    # Find the post in our list and update its comments
    updated_posts = Enum.map(socket.assigns.posts, fn post ->
      if post.id == comment.post_id do
        %{post | comments: [comment | (post.comments || [])]}
      else
        post
      end
    end)
    
    # Also update the single post view if we're looking at that post
    socket = if socket.assigns.post && socket.assigns.post.id == comment.post_id do
      updated_post = %{socket.assigns.post | comments: [comment | (socket.assigns.post.comments || [])]}
      assign(socket, :post, updated_post)
    else
      socket
    end
    
    {:noreply, assign(socket, :posts, updated_posts)}
  end

  @impl true
  def handle_info({:reaction_added, reaction}, socket) do
    # Find the post in our list and update its reactions
    updated_posts = Enum.map(socket.assigns.posts, fn post ->
      if post.id == reaction.post_id do
        %{post | reactions: [reaction | (post.reactions || [])]}
      else
        post
      end
    end)
    
    # Also update the single post view if we're looking at that post
    socket = if socket.assigns.post && socket.assigns.post.id == reaction.post_id do
      updated_post = %{socket.assigns.post | reactions: [reaction | (socket.assigns.post.reactions || [])]}
      assign(socket, :post, updated_post)
    else
      socket
    end
    
    {:noreply, assign(socket, :posts, updated_posts)}
  end
  
  @impl true
  def handle_info({:reaction_removed, %{post_id: post_id, emoji: emoji, user_id: user_id}}, socket) do
    # Find the post in our list and remove the reaction
    updated_posts = Enum.map(socket.assigns.posts, fn post ->
      if post.id == post_id do
        updated_reactions = Enum.reject(post.reactions, fn r -> 
          r.post_id == post_id && r.emoji == emoji && r.user_id == user_id
        end)
        %{post | reactions: updated_reactions}
      else
        post
      end
    end)
    
    # Also update the single post view if we're looking at that post
    socket = if socket.assigns.post && socket.assigns.post.id == post_id do
      updated_reactions = Enum.reject(socket.assigns.post.reactions, fn r -> 
        r.post_id == post_id && r.emoji == emoji && r.user_id == user_id
      end)
      updated_post = %{socket.assigns.post | reactions: updated_reactions}
      assign(socket, :post, updated_post)
    else
      socket
    end
    
    {:noreply, assign(socket, :posts, updated_posts)}
  end
end
