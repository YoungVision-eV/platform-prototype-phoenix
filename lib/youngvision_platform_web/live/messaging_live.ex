defmodule YoungvisionPlatformWeb.MessagingLive do
  use YoungvisionPlatformWeb, :live_view

  alias YoungvisionPlatform.Messaging
  alias YoungvisionPlatform.Accounts
  alias Phoenix.LiveView.JS
  
  # Helper function to format message timestamps
  defp format_time(datetime) do
    now = DateTime.utc_now()
    
    cond do
      # Today
      DateTime.to_date(datetime) == DateTime.to_date(now) ->
        Calendar.strftime(datetime, "%H:%M")
        
      # This year
      datetime.year == now.year ->
        Calendar.strftime(datetime, "%b %d")
        
      # Different year
      true ->
        Calendar.strftime(datetime, "%b %d, %Y")
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      # Subscribe to messages for the current user
      if connected?(socket) do
        Messaging.subscribe_to_messages(socket.assigns.current_user.id)
      end
      
      conversations = Messaging.list_conversations(socket.assigns.current_user.id)
      unread_count = Messaging.count_unread_messages(socket.assigns.current_user.id)
      
      {:ok, 
        socket
        |> assign(:conversations, conversations)
        |> assign(:selected_conversation, nil)
        |> assign(:messages, [])
        |> assign(:unread_count, unread_count)
        |> assign(:message_form, to_form(%{"content" => ""}))
      }
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    {id, _} = Integer.parse(id)
    
    if id == socket.assigns.current_user.id do
      {:noreply, 
        socket
        |> put_flash(:error, "You cannot message yourself")
        |> push_patch(to: ~p"/messages")
      }
    else
      recipient = Accounts.get_user!(id)
      messages = Messaging.list_conversation(socket.assigns.current_user.id, recipient.id)
      
      # Mark messages from recipient as read
      Messaging.mark_all_as_read(recipient.id, socket.assigns.current_user.id)
      
      # Update unread count after marking messages as read
      unread_count = Messaging.count_unread_messages(socket.assigns.current_user.id)
      
      {:noreply, 
        socket
        |> assign(:selected_conversation, recipient)
        |> assign(:messages, messages)
        |> assign(:message_form, to_form(%{"content" => ""}))
        |> assign(:unread_count, unread_count)
      }
    end
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    # Preload users for the new message modal
    users = Accounts.list_users()
    |> Enum.filter(fn user -> user.id != socket.assigns.current_user.id end)
    
    {:noreply, 
      socket
      |> assign(:selected_conversation, nil)
      |> assign(:users, users)
    }
  end
  
  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :selected_conversation, nil)}
  end

  @impl true
  def handle_event("send-message", %{"content" => content}, socket) do
    if content != "" do
      case Messaging.create_message(
        socket.assigns.current_user,
        socket.assigns.selected_conversation,
        %{"content" => content}
      ) do
        {:ok, _message} ->
          # Reload the entire conversation to ensure consistency
          messages = Messaging.list_conversation(
            socket.assigns.current_user.id, 
            socket.assigns.selected_conversation.id
          )
          
          {:noreply, 
            socket
            |> assign(:messages, messages)
            |> assign(:message_form, to_form(%{"content" => ""}))
          }
          
        {:error, _changeset} ->
          {:noreply, 
            socket
            |> put_flash(:error, "Could not send message")
          }
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("load-user-list", _params, socket) do
    # Get all users except the current user
    users = Accounts.list_users()
    |> Enum.filter(fn user -> user.id != socket.assigns.current_user.id end)
    
    {:noreply, assign(socket, :users, users)}
  end
  
  @impl true
  def handle_info({:new_message, message}, socket) do
    # Only process the message if it's relevant to the current conversation
    if socket.assigns.selected_conversation && 
       (message.sender_id == socket.assigns.selected_conversation.id || 
        message.recipient_id == socket.assigns.selected_conversation.id) do
      
      # Mark the message as read if we're in the conversation
      if message.recipient_id == socket.assigns.current_user.id do
        Messaging.mark_as_read(message)
      end
      
      # Reload the entire conversation to ensure consistency
      messages = Messaging.list_conversation(
        socket.assigns.current_user.id, 
        socket.assigns.selected_conversation.id
      )
      
      # Update unread count
      unread_count = Messaging.count_unread_messages(socket.assigns.current_user.id)
      
      {:noreply, 
        socket
        |> assign(:messages, messages)
        |> assign(:unread_count, unread_count)
      }
    else
      # If we're not in the conversation, just update the unread count and conversations list
      unread_count = Messaging.count_unread_messages(socket.assigns.current_user.id)
      conversations = Messaging.list_conversations(socket.assigns.current_user.id)
      
      {:noreply, 
        socket
        |> assign(:unread_count, unread_count)
        |> assign(:conversations, conversations)
      }
    end
  end
end
