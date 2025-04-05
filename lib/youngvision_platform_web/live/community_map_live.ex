defmodule YoungvisionPlatformWeb.CommunityMapLive do
  use YoungvisionPlatformWeb, :live_view
  alias YoungvisionPlatform.Accounts
  alias YoungvisionPlatform.Community
  alias YoungvisionPlatform.Accounts.ProfilePictureHelper

  def mount(_params, _session, socket) do
    # Get users with location data
    users_with_location = Accounts.list_users_with_location()

    # Add profile picture URLs to each user
    users_with_profile_pics =
      Enum.map(users_with_location, fn user ->
        Map.put(user, :profile_picture_url, ProfilePictureHelper.profile_picture_url(user))
      end)
    
    # Get events with location data
    events = Community.list_events()
    events_with_location = Enum.filter(events, fn event -> 
      event.latitude != nil && event.longitude != nil 
    end)
    
    # Prepare events for JSON encoding by converting to simple maps
    # This ensures we only include the fields we need and avoid circular references
    prepared_events = Enum.map(events_with_location, fn event ->
      %{
        id: event.id,
        title: event.title,
        description: event.description,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        start_time: event.start_time,
        end_time: event.end_time,
        user_id: event.user_id
      }
    end)

    {:ok, assign(socket, users: users_with_profile_pics, events: prepared_events)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <.header class="text-center">
        Community Map
        <:subtitle>See where our community members are located</:subtitle>
      </.header>

      <div class="mt-8 bg-orange-100 p-6 rounded-lg border border-orange-100 shadow-sm">
        <div
          id="community-map"
          class="h-[500px] w-full rounded-lg shadow-sm"
          phx-hook="CommunityMap"
          data-users={Jason.encode!(@users)}
          data-events={Jason.encode!(@events)}
        >
        </div>

        <div class="mt-4 text-sm text-orange-700">
          <div class="flex items-center gap-4 mb-2">
            <div class="flex items-center">
              <div class="w-4 h-4 rounded-full bg-blue-500 mr-2"></div>
              <span>Community Members</span>
            </div>
            <div class="flex items-center">
              <div class="w-4 h-4 rounded-full bg-red-500 mr-2"></div>
              <span>Events</span>
            </div>
          </div>
          <p>Click on a pin to see details about community members and events!</p>
          <p class="mt-2">
            Want to add your location? Update your profile on your <.link
              navigate={~p"/users/#{@current_user.id}"}
              class="font-semibold text-brand hover:text-orange-700 hover:underline"
            >profile page</.link>.
          </p>
        </div>
      </div>
    </div>
    """
  end
end
