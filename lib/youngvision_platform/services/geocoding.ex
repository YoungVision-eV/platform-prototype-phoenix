defmodule YoungvisionPlatform.Services.Geocoding do
  @moduledoc """
  Service for geocoding location names to coordinates.
  Uses the Nominatim OpenStreetMap API.
  """

  @doc """
  Geocodes a location name to latitude and longitude.
  Returns {:ok, {latitude, longitude}} on success or {:error, reason} on failure.
  """
  def geocode(location) when is_binary(location) and location != "" do
    url = "https://nominatim.openstreetmap.org/search"
    
    params = [
      q: location,
      format: "json",
      limit: 1,
      addressdetails: 0
    ]
    
    query_string = URI.encode_query(params)
    full_url = "#{url}?#{query_string}"
    
    headers = [
      {"User-Agent", "YoungvisionPlatform/1.0"},
      {"Accept", "application/json"}
    ]
    
    # Use HTTPoison for HTTP requests
    IO.puts("Making HTTP request to: #{full_url}")
    case HTTPoison.get(full_url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts("Received successful response")
        parse_response(body)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("HTTP error: #{status_code}")
        {:error, "HTTP error: #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Request failed: #{inspect(reason)}")
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end
  
  def geocode(_), do: {:error, "Invalid location"}
  
  defp parse_response(body) do
    IO.puts("Parsing response body: #{inspect(String.slice(body, 0, 100))}...")
    case Jason.decode(body) do
      {:ok, results} when is_list(results) and length(results) > 0 ->
        case Enum.at(results, 0) do
          %{"lat" => lat, "lon" => lon} ->
            IO.puts("Found coordinates: lat=#{lat}, lon=#{lon}")
            try do
              {latitude, _} = Float.parse(lat)
              {longitude, _} = Float.parse(lon)
              {:ok, {latitude, longitude}}
            rescue
              e ->
                IO.puts("Error parsing coordinates: #{inspect(e)}")
                {:error, "Invalid coordinates format"}
            end
          _ ->
            IO.puts("Response missing lat/lon fields")
            {:error, "Response missing coordinates"}
        end
      {:ok, []} ->
        IO.puts("Empty results array")
        {:error, "Location not found"}
      {:ok, other} ->
        IO.puts("Unexpected response format: #{inspect(other)}")
        {:error, "Unexpected response format"}
      {:error, reason} ->
        IO.inspect(reason, label: "JSON parse error")
        IO.inspect(body, label: "Response body")
        {:error, "Failed to parse response"}
    end
  end
end
