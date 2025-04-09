defmodule YoungvisionPlatformWeb.PostsLive do
  use YoungvisionPlatformWeb, :live_view

  alias YoungvisionPlatform.Community

  @impl true
  def mount(params, _session, socket) do
    # Check if current_user is in the assigns
    current_user = Map.get(socket.assigns, :current_user)

    if current_user do
      # Subscribe to post updates when the LiveView connects
      if connected?(socket) do
        Community.subscribe_to_posts()
      end

      # Make sure posts are properly preloaded with all associations
      # Pass the current user to filter out posts from groups the user is not a member of
      all_posts = Community.list_posts(current_user)

      # Get available check-in posts
      available_checkins = Community.list_available_checkin_posts(current_user)

      # Filter out check-in posts from the regular posts list to avoid duplication
      regular_posts = Enum.filter(all_posts, fn post -> post.post_type != "checkin" end)

      {:ok,
       socket
       |> assign(:posts, regular_posts)
       |> assign(:available_checkins, available_checkins)
       |> assign(:post, nil)
       |> assign(:group_id, params["group_id"])
       |> assign(:comment_form, to_form(%{"content" => ""}))}
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  rescue
    Ecto.NoResultsError ->
      {:noreply,
       socket
       |> put_flash(:error, "You don't have permission to view this post or it doesn't exist.")
       |> push_navigate(to: ~p"/posts")}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Community Feed")
  end

  defp apply_action(socket, :new, params) do
    group_id = params["group_id"]
    page_title = if group_id, do: "New Group Post", else: "New Post"

    socket
    |> assign(:page_title, page_title)
    |> assign(:group_id, group_id)
    |> assign(:post_type, params["post_type"] || "regular")
    |> assign(:checkin_type, params["checkin_type"])
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    # Pass the current user to check if they have access to the post
    post = Community.get_post!(id, socket.assigns.current_user)

    socket
    |> assign(:page_title, post.title)
    |> assign(:post, post)
  end

  @impl true
  def handle_event("create-post", %{"post" => post_params}, socket) do
    # Add group_id to post_params if it exists in socket assigns
    post_params =
      if socket.assigns.group_id do
        Map.put(post_params, "group_id", socket.assigns.group_id)
      else
        post_params
      end

    # Check if this is a regular post or a check-in post
    case socket.assigns.post_type do
      "checkin" ->
        case Community.create_checkin_post(
               socket.assigns.current_user,
               socket.assigns.checkin_type,
               post_params
             ) do
          {:ok, post} ->
            # If post was created for a group, redirect back to the group
            redirect_path =
              if socket.assigns.group_id do
                ~p"/groups/#{socket.assigns.group_id}"
              else
                ~p"/posts/#{post.id}"
              end

            {:noreply,
             socket
             |> put_flash(:info, "Check-in post created successfully")
             |> push_navigate(to: redirect_path)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Error creating check-in post")
             |> assign(:changeset, changeset)}
        end

      _ ->
        case Community.create_post(socket.assigns.current_user, post_params) do
          {:ok, post} ->
            # If post was created for a group, redirect back to the group
            redirect_path =
              if socket.assigns.group_id do
                ~p"/groups/#{socket.assigns.group_id}"
              else
                ~p"/posts/#{post.id}"
              end

            {:noreply,
             socket
             |> put_flash(:info, "Post created successfully")
             |> push_navigate(to: redirect_path)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Error creating post")
             |> assign(:changeset, changeset)}
        end
    end
  end

  @impl true
  def handle_event("add-comment", %{"content" => content}, socket) do
    case Community.create_comment(socket.assigns.current_user, socket.assigns.post, %{
           "content" => content
         }) do
      {:ok, _comment} ->
        {:noreply,
         socket
         |> assign(:comment_form, to_form(%{"content" => ""}))
         |> put_flash(:info, "Comment added successfully")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error adding comment")}
    end
  end

  @impl true
  def handle_event("add-reaction", %{"post_id" => post_id, "emoji" => emoji}, socket) do
    post = Community.get_post!(post_id, socket.assigns.current_user)

    case Community.toggle_reaction(socket.assigns.current_user, post, emoji) do
      {:ok, _status, _reaction} ->
        {:noreply, socket}

      {:ok, :deleted} ->
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error adding reaction")}
    end
  end

  @impl true
  def handle_event("join-checkin", %{"post_id" => post_id}, socket) do
    post = Community.get_post!(post_id, socket.assigns.current_user)

    case Community.join_checkin_post(socket.assigns.current_user, post) do
      {:ok, _updated_post} ->
        {:noreply, socket |> put_flash(:info, "Successfully joined check-in!")}

      {:error, :already_joined} ->
        {:noreply, socket |> put_flash(:error, "You've already joined this check-in")}

      {:error, :post_full} ->
        {:noreply, socket |> put_flash(:error, "This check-in is already full")}

      {:error, :not_a_checkin_post} ->
        {:noreply, socket |> put_flash(:error, "This is not a check-in post")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error joining check-in")}
    end
  end

  # Handle broadcast events
  @impl true
  def handle_info({:post_created, post}, socket) do
    # Only add the post to the list if it's not from a group or if the user is a member of the group
    current_user = socket.assigns.current_user

    should_add_post =
      cond do
        # Never add check-in posts to the regular posts list
        post.post_type == "checkin" ->
          false

        # If the post doesn't belong to a group, always show it
        is_nil(post.group_id) ->
          true

        # If the post belongs to a group, check if the user is a member
        true ->
          # Check if the user is a member of the group
          YoungvisionPlatform.Community.GroupFunctions.is_member?(current_user.id, post.group_id)
      end

    # If it's a check-in post and not full, add it to available check-ins
    updated_checkins =
      if post.post_type == "checkin" && !post.is_full &&
           (is_nil(post.group_id) ||
              YoungvisionPlatform.Community.GroupFunctions.is_member?(
                current_user.id,
                post.group_id
              )) do
        [post | socket.assigns.available_checkins]
        |> Enum.sort_by(fn p -> p.inserted_at end, {:desc, DateTime})
      else
        socket.assigns.available_checkins
      end

    # Update regular posts if needed
    updated_posts =
      if should_add_post do
        [post | socket.assigns.posts]
        |> Enum.sort_by(fn p -> p.inserted_at end, {:desc, DateTime})
      else
        socket.assigns.posts
      end

    {:noreply,
     socket
     |> assign(:posts, updated_posts)
     |> assign(:available_checkins, updated_checkins)}
  end

  @impl true
  def handle_info({:comment_added, comment}, socket) do
    # Find the post in our list and update its comments
    updated_posts =
      Enum.map(socket.assigns.posts, fn post ->
        if post.id == comment.post_id do
          %{post | comments: [comment | post.comments || []]}
        else
          post
        end
      end)

    # Also update the single post view if we're looking at that post
    socket =
      if socket.assigns.post && socket.assigns.post.id == comment.post_id do
        updated_post = %{
          socket.assigns.post
          | comments: [comment | socket.assigns.post.comments || []]
        }

        assign(socket, :post, updated_post)
      else
        socket
      end

    {:noreply, assign(socket, :posts, updated_posts)}
  end

  @impl true
  def handle_info({:reaction_added, reaction}, socket) do
    # Find the post in our list and update its reactions
    updated_posts =
      Enum.map(socket.assigns.posts, fn post ->
        if post.id == reaction.post_id do
          %{post | reactions: [reaction | post.reactions || []]}
        else
          post
        end
      end)

    # Also update the single post view if we're looking at that post
    socket =
      if socket.assigns.post && socket.assigns.post.id == reaction.post_id do
        updated_post = %{
          socket.assigns.post
          | reactions: [reaction | socket.assigns.post.reactions || []]
        }

        assign(socket, :post, updated_post)
      else
        socket
      end

    {:noreply, assign(socket, :posts, updated_posts)}
  end

  @impl true
  def handle_info(
        {:reaction_removed, %{post_id: post_id, emoji: emoji, user_id: user_id}},
        socket
      ) do
    # Find the post in our list and remove the reaction
    updated_posts =
      Enum.map(socket.assigns.posts, fn post ->
        if post.id == post_id do
          updated_reactions =
            Enum.reject(post.reactions, fn r ->
              r.post_id == post_id && r.emoji == emoji && r.user_id == user_id
            end)

          %{post | reactions: updated_reactions}
        else
          post
        end
      end)

    # Also update the single post view if we're looking at that post
    socket =
      if socket.assigns.post && socket.assigns.post.id == post_id do
        updated_reactions =
          Enum.reject(socket.assigns.post.reactions, fn r ->
            r.post_id == post_id && r.emoji == emoji && r.user_id == user_id
          end)

        updated_post = %{socket.assigns.post | reactions: updated_reactions}
        assign(socket, :post, updated_post)
      else
        socket
      end

    {:noreply, assign(socket, :posts, updated_posts)}
  end

  @impl true
  def handle_info({:checkin_joined, post}, socket) do
    # Update the post in our list of posts
    updated_posts =
      Enum.map(socket.assigns.posts, fn p ->
        if p.id == post.id, do: post, else: p
      end)

    # Update the post in our list of available check-ins
    updated_checkins =
      Enum.map(socket.assigns.available_checkins, fn p ->
        if p.id == post.id, do: post, else: p
      end)

    # Also update the single post view if we're looking at that post
    socket =
      if socket.assigns.post && socket.assigns.post.id == post.id do
        assign(socket, :post, post)
      else
        socket
      end

    {:noreply,
     socket
     |> assign(:posts, updated_posts)
     |> assign(:available_checkins, updated_checkins)}
  end

  @impl true
  def handle_info({:checkin_full, post}, socket) do
    # Update the post in our list of posts
    updated_posts =
      Enum.map(socket.assigns.posts, fn p ->
        if p.id == post.id, do: post, else: p
      end)

    # Remove the post from our list of available check-ins
    updated_checkins = Enum.reject(socket.assigns.available_checkins, fn p -> p.id == post.id end)

    # Also update the single post view if we're looking at that post
    socket =
      if socket.assigns.post && socket.assigns.post.id == post.id do
        assign(socket, :post, post)
      else
        socket
      end

    {:noreply,
     socket
     |> assign(:posts, updated_posts)
     |> assign(:available_checkins, updated_checkins)}
  end
end
