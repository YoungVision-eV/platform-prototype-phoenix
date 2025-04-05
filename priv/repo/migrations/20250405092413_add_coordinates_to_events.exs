defmodule YoungvisionPlatform.Repo.Migrations.AddCoordinatesToEvents do
  use Ecto.Migration
  import Ecto.Query

  def change do
    alter table(:events) do
      add :latitude, :float
      add :longitude, :float
    end

    # After adding the columns, update existing events with coordinates
    flush()
    update_event_coordinates()
  end

  # Function to update existing events with coordinates
  defp update_event_coordinates do
    # This code will only run during migration
    Code.ensure_loaded?(YoungvisionPlatform.Community.Event)
    Code.ensure_loaded?(YoungvisionPlatform.Services.Geocoding)

    # Get the repo module
    repo = YoungvisionPlatform.Repo

    # Get all existing events
    events_query = from e in "events", select: %{id: e.id, location: e.location}
    events = repo.all(events_query)

    for event <- events do
      if event.location && event.location != "" do
        case YoungvisionPlatform.Services.Geocoding.geocode(event.location) do
          {:ok, {latitude, longitude}} ->
            # Update the event with the new coordinates
            repo.query!("UPDATE events SET latitude = $1, longitude = $2 WHERE id = $3", [latitude, longitude, event.id])
            IO.puts("Updated coordinates for event ID #{event.id} at #{event.location}")
          
          {:error, reason} ->
            IO.puts("Failed to geocode location for event ID #{event.id} at #{event.location}: #{reason}")
        end
      end
    end

    IO.puts("Event coordinates update completed!")
  end
end
