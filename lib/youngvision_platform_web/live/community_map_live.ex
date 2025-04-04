defmodule YoungvisionPlatformWeb.CommunityMapLive do
  use YoungvisionPlatformWeb, :live_view
  alias YoungvisionPlatform.Accounts

  def mount(_params, _session, socket) do
    users_with_location = Accounts.list_users_with_location()
    
    {:ok, assign(socket, users: users_with_location)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <.header class="text-center">
        Community Map
        <:subtitle>See where our community members are located</:subtitle>
      </.header>

      <div class="mt-8 bg-orange-100 p-6 rounded-lg border border-orange-100 shadow-sm">
        <div id="community-map" class="h-[500px] w-full rounded-lg shadow-sm" phx-hook="CommunityMap" data-users={Jason.encode!(@users)}></div>
        
        <div class="mt-4 text-sm text-orange-700">
          <p>Each pin represents a community member's location. Click on a pin to see who's there!</p>
          <p class="mt-2">Want to add your location? Update your profile on your <.link navigate={~p"/users/#{@current_user.id}"} class="font-semibold text-brand hover:text-orange-700 hover:underline">profile page</.link>.</p>
        </div>
      </div>
    </div>
    """
  end
end
