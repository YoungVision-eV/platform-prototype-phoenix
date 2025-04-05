# Script for updating event coordinates based on their locations
# Run with: mix run priv/repo/update_event_coordinates.exs

alias YoungvisionPlatform.Repo
alias YoungvisionPlatform.Community.Event

# Get all existing events
events = Repo.all(Event)

for event <- events do
  # Skip events that already have coordinates
  if is_nil(event.latitude) or is_nil(event.longitude) do
    # Create a changeset with the existing location to trigger coordinate calculation
    changeset = Event.changeset(event, %{location: event.location})
    
    # Update the event with the new coordinates
    Repo.update!(changeset)
    
    IO.puts("Updated coordinates for event: #{event.title} at #{event.location}")
  end
end

IO.puts("Event coordinates update completed!")
