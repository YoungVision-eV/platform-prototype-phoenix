defmodule YoungvisionPlatform.Presence do
  @moduledoc """
  Provides presence tracking capabilities.

  This module uses Phoenix.Presence to track connected users and their metadata.
  """
  use Phoenix.Presence,
    otp_app: :youngvision_platform,
    pubsub_server: YoungvisionPlatform.PubSub
end
