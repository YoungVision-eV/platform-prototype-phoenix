defmodule YoungvisionPlatform.Accounts.ProfilePictureHelper do
  @moduledoc """
  Helper functions for handling user profile pictures.
  """

  @doc """
  Returns the URL for a user's profile picture.
  If the user has uploaded a profile picture, returns the URL to the uploaded file.
  Otherwise, returns a URL to a generated avatar from DiceBear API.
  """
  def profile_picture_url(user) do
    if user.profile_picture && user.profile_picture != "" do
      "/uploads/profile_pictures/#{user.profile_picture}"
    else
      # Use DiceBear API as fallback
      "https://api.dicebear.com/9.x/fun-emoji/svg?seed=#{URI.encode(user.email)}"
    end
  end

  @doc """
  Saves an uploaded profile picture to disk.
  Returns the filename of the saved file.
  """
  def save_profile_picture(upload) do
    # Create a unique filename based on timestamp and random string
    extension = Path.extname(upload.filename)
    filename = "#{System.os_time()}_#{:crypto.strong_rand_bytes(8) |> Base.url_encode64()}"
    filename_with_extension = "#{filename}#{extension}"
    
    # Ensure the directory exists
    File.mkdir_p!("uploads/profile_pictures")
    
    # Save the file
    dest = Path.join("uploads/profile_pictures", filename_with_extension)
    File.cp!(upload.path, dest)
    
    # Return the filename
    filename_with_extension
  end
end
