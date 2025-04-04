defmodule YoungvisionPlatformWeb.CommunityCalendarLive do
  use YoungvisionPlatformWeb, :live_view

  alias YoungvisionPlatform.Community
  alias YoungvisionPlatform.Community.Event
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    IO.inspect(socket.assigns.current_user, label: "Current user in mount")
    
    current_date = Date.utc_today()
    start_of_month = Date.beginning_of_month(current_date)
    end_of_month = Date.end_of_month(current_date)
    
    start_datetime = DateTime.new!(start_of_month, ~T[00:00:00], "Etc/UTC")
    end_datetime = DateTime.new!(end_of_month, ~T[23:59:59], "Etc/UTC")
    
    events = Community.list_events_in_range(start_datetime, end_datetime)
    
    {:ok, 
      socket
      |> assign(:current_date, current_date)
      |> assign(:events, events)
      |> assign(:form, to_form(Community.change_event(%Event{})))
      |> assign(:show_modal, false)
      |> assign(:modal_type, nil)
      |> assign(:selected_event, nil)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Community Calendar")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:show_modal, true)
    |> assign(:modal_type, :new)
    |> assign(:form, to_form(Community.change_event(%Event{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Community.get_event!(id)
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:show_modal, true)
    |> assign(:modal_type, :edit)
    |> assign(:selected_event, event)
    |> assign(:form, to_form(Community.change_event(event)))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    # Explicitly reload the event with user association to ensure it's fresh
    event = Community.get_event!(id)
    IO.inspect(event, label: "Event in show action")
    IO.inspect(event.user, label: "Event user in show action")
    
    socket
    |> assign(:page_title, event.title)
    |> assign(:show_modal, true)
    |> assign(:modal_type, :show)
    |> assign(:selected_event, event)
  end

  @impl true
  def handle_event("change-month", %{"direction" => direction}, socket) do
    current_date = socket.assigns.current_date
    
    new_date = case direction do
      "prev" -> Date.add(current_date, -Date.days_in_month(current_date))
      "next" -> Date.add(current_date, Date.days_in_month(current_date))
    end
    
    start_of_month = Date.beginning_of_month(new_date)
    end_of_month = Date.end_of_month(new_date)
    
    start_datetime = DateTime.new!(start_of_month, ~T[00:00:00], "Etc/UTC")
    end_datetime = DateTime.new!(end_of_month, ~T[23:59:59], "Etc/UTC")
    
    events = Community.list_events_in_range(start_datetime, end_datetime)
    
    {:noreply, 
      socket
      |> assign(:current_date, new_date)
      |> assign(:events, events)
    }
  end

  @impl true
  def handle_event("close-modal", _, socket) do
    {:noreply, 
      socket
      |> assign(:show_modal, false)
      |> assign(:modal_type, nil)
      |> assign(:selected_event, nil)
      |> push_patch(to: ~p"/community/calendar")
    }
  end

  @impl true
  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.modal_type, event_params)
  end

  defp save_event(socket, :new, event_params) do
    IO.inspect(socket.assigns.current_user, label: "Current user in save_event")
    
    case Community.create_event(socket.assigns.current_user, event_params) do
      {:ok, event} ->
        IO.inspect(event, label: "Event after creation")
        IO.inspect(event.user, label: "Event user after creation")
        
        start_of_month = Date.beginning_of_month(socket.assigns.current_date)
        end_of_month = Date.end_of_month(socket.assigns.current_date)
        
        start_datetime = DateTime.new!(start_of_month, ~T[00:00:00], "Etc/UTC")
        end_datetime = DateTime.new!(end_of_month, ~T[23:59:59], "Etc/UTC")
        
        events = Community.list_events_in_range(start_datetime, end_datetime)
        
        {:noreply,
          socket
          |> assign(:events, events)
          |> assign(:show_modal, false)
          |> assign(:modal_type, nil)
          |> assign(:selected_event, event)
          |> put_flash(:info, "Event created successfully")
          |> push_patch(to: ~p"/community/calendar/#{event.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :edit, event_params) do
    event = socket.assigns.selected_event

    case Community.update_event(event, event_params) do
      {:ok, updated_event} ->
        start_of_month = Date.beginning_of_month(socket.assigns.current_date)
        end_of_month = Date.end_of_month(socket.assigns.current_date)
        
        start_datetime = DateTime.new!(start_of_month, ~T[00:00:00], "Etc/UTC")
        end_datetime = DateTime.new!(end_of_month, ~T[23:59:59], "Etc/UTC")
        
        events = Community.list_events_in_range(start_datetime, end_datetime)
        
        {:noreply,
          socket
          |> assign(:events, events)
          |> assign(:show_modal, false)
          |> assign(:modal_type, nil)
          |> assign(:selected_event, updated_event)
          |> put_flash(:info, "Event updated successfully")
          |> push_patch(to: ~p"/community/calendar/#{updated_event.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp days_in_month(date) do
    Date.days_in_month(date)
  end

  defp first_day_of_month(date) do
    date
    |> Date.beginning_of_month()
    |> Date.day_of_week()
    |> then(fn day -> if day == 7, do: 0, else: day end) # Convert Sunday from 7 to 0 for easier calculations
  end

  defp events_for_day(events, date) do
    Enum.filter(events, fn event -> 
      event_date = DateTime.to_date(event.start_time)
      Date.compare(event_date, date) == :eq
    end)
  end
end
