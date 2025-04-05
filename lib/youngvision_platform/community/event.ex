defmodule YoungvisionPlatform.Community.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :description,
             :location,
             :latitude,
             :longitude,
             :start_time,
             :end_time,
             :user_id
           ]}

  schema "events" do
    field :description, :string
    field :title, :string
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    belongs_to :user, YoungvisionPlatform.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title,
      :description,
      :start_time,
      :end_time,
      :location,
      :latitude,
      :longitude,
      :user_id
    ])
    |> validate_required([:title, :description, :start_time, :end_time, :location, :user_id])
    |> validate_location()
  end

  @doc """
  Validates the location and updates latitude and longitude if location is changed.
  """
  defp validate_location(changeset) do
    changeset
    |> validate_length(:location, max: 255)
    |> maybe_update_coordinates()
  end

  @doc """
  Updates latitude and longitude if location is changed.
  Uses the Nominatim geocoding service to get coordinates for the location.
  """
  defp maybe_update_coordinates(changeset) do
    case get_change(changeset, :location) do
      nil ->
        changeset

      location when is_binary(location) and location != "" ->
        case YoungvisionPlatform.Services.Geocoding.geocode(location) do
          {:ok, {latitude, longitude}} ->
            changeset
            |> put_change(:latitude, latitude)
            |> put_change(:longitude, longitude)

          {:error, _reason} ->
            # If geocoding fails, we'll still save the location name but without coordinates
            changeset
        end

      _other ->
        # If location is empty or invalid, don't update coordinates
        changeset
    end
  end
end
