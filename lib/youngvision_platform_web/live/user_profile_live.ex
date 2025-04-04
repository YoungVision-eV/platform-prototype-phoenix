defmodule YoungvisionPlatformWeb.UserProfileLive do
  use YoungvisionPlatformWeb, :live_view

  alias YoungvisionPlatform.Accounts
  alias YoungvisionPlatform.Community

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    current_user = socket.assigns.current_user
    
    # Get the user whose profile we're viewing
    user = Accounts.get_user!(id)
    
    # Check if this is the current user's profile
    is_current_user = current_user && current_user.id == user.id
    
    # Get user's posts
    posts = Community.list_posts_by_user(user)
    
    {:ok, 
      socket
      |> assign(:page_title, "#{user.display_name}'s Profile")
      |> assign(:user, user)
      |> assign(:is_current_user, is_current_user)
      |> assign(:posts, posts)
      |> assign(:profile_form, to_form(%{}))
    }
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  
  defp apply_action(socket, :show, _params) do
    socket
  end
  
  defp apply_action(socket, :edit, _params) do
    # Only allow editing if it's the current user's profile
    if socket.assigns.is_current_user do
      profile_form = 
        socket.assigns.current_user
        |> Accounts.change_user_profile()
        |> to_form()
      
      socket
      |> assign(:page_title, "Edit Profile")
      |> assign(:profile_form, profile_form)
    else
      socket
      |> put_flash(:error, "You can only edit your own profile")
      |> push_navigate(to: ~p"/users/#{socket.assigns.user.id}")
    end
  end

  @impl true
  def handle_event("save-profile", %{"user" => profile_params}, socket) do
    # Only allow saving if it's the current user's profile
    if socket.assigns.is_current_user do
      # Process location data for geocoding
      location = profile_params["location"]
      
      profile_params = if location && location != "" do
        case YoungvisionPlatform.Services.Geocoding.geocode(location) do
          {:ok, {latitude, longitude}} ->
            Map.merge(profile_params, %{"latitude" => latitude, "longitude" => longitude})
          {:error, _reason} ->
            # If geocoding fails, we'll still save the location name but without coordinates
            profile_params
        end
      else
        # If location is empty, clear the coordinates
        Map.merge(profile_params, %{"latitude" => nil, "longitude" => nil})
      end
      
      case Accounts.update_user_profile(socket.assigns.current_user, profile_params) do
        {:ok, user} ->
          # Create appropriate success message based on geocoding result
          location_message = cond do
            user.location && user.latitude && user.longitude ->
              "Profile updated successfully and location placed on the map."
            user.location && (is_nil(user.latitude) || is_nil(user.longitude)) ->
              "Profile updated successfully, but location couldn't be placed on the map. Please try a more specific location."
            true ->
              "Profile updated successfully."
          end
          
          {:noreply,
            socket
            |> put_flash(:info, location_message)
            |> push_navigate(to: ~p"/users/#{user.id}")
          }
        
        {:error, changeset} ->
          {:noreply,
            socket
            |> put_flash(:error, "Error updating profile")
            |> assign(:profile_form, to_form(changeset))
          }
      end
    else
      {:noreply,
        socket
        |> put_flash(:error, "You can only edit your own profile")
        |> push_navigate(to: ~p"/users/#{socket.assigns.user.id}")
      }
    end
  end
end
