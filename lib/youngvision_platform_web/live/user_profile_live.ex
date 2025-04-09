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

    # Get user's posts, filtering out posts from groups the current user is not a member of
    posts = Community.list_posts_by_user(user, current_user)

    {:ok,
     socket
     |> assign(:page_title, "#{user.display_name}'s Profile")
     |> assign(:user, user)
     |> assign(:is_current_user, is_current_user)
     |> assign(:posts, posts)
     |> assign(:profile_form, to_form(%{}))
     |> allow_upload(:profile_picture,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       # 5MB limit
       max_file_size: 5_000_000
     )}
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
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save-profile", %{"user" => profile_params}, socket) do
    # Only allow saving if it's the current user's profile
    if socket.assigns.is_current_user do
      # Process location data for geocoding
      location = profile_params["location"]

      profile_params =
        if location && location != "" do
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

      # Process uploaded profile picture if any
      profile_params =
        case uploaded_entries(socket, :profile_picture) do
          [] ->
            # No new upload, keep existing profile picture
            profile_params

          _entries ->
            # Process the uploaded file(s)
            uploaded_filename =
              consume_uploaded_entries(socket, :profile_picture, fn %{path: path}, entry ->
                # Get file extension from the original file
                extension = Path.extname(entry.client_name)

                # Create a unique filename with timestamp and user ID
                # Format: user_id_timestamp.extension
                filename =
                  "user_#{socket.assigns.current_user.id}_#{System.os_time()}#{extension}"

                dest = Path.join(["uploads", "profile_pictures", filename])

                # Ensure directory exists
                File.mkdir_p!(Path.dirname(dest))

                # Copy the file
                File.cp!(path, dest)

                # Return the filename to be stored in the database
                {:ok, filename}
              end)
              |> List.first()

            # Add the filename to the profile params
            Map.put(profile_params, "profile_picture", uploaded_filename)
        end

      case Accounts.update_user_profile(socket.assigns.current_user, profile_params) do
        {:ok, user} ->
          # Create appropriate success message based on geocoding result
          location_message =
            cond do
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
           |> push_navigate(to: ~p"/users/#{user.id}")}

        {:error, changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Error updating profile")
           |> assign(:profile_form, to_form(changeset))}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "You can only edit your own profile")
       |> push_navigate(to: ~p"/users/#{socket.assigns.user.id}")}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :profile_picture, ref)}
  end

  defp error_to_string(:too_large), do: "File is too large (max 5MB)"

  defp error_to_string(:not_accepted),
    do: "Unacceptable file type (only JPG, PNG, and WebP allowed)"

  defp error_to_string(:too_many_files), do: "Too many files selected (max 1)"
end
