defmodule LivechatWeb.RoomLive do
  use LivechatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"room" => room_id}, _session, socket) do
    topic = "room: " <> room_id
    username = MnemonicSlugs.generate_slug(2)
    if connected?(socket), do: LivechatWeb.Endpoint.subscribe(topic)

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       messages: [
         %{
           id: UUID.uuid4(),
           username: "system",
           content: "#{username} joined."
         }
       ],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{id: UUID.uuid4(), username: socket.assigns.username, content: message}

    LivechatWeb.Endpoint.broadcast(
      socket.assigns.topic,
      "new-message",
      message
    )

    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end
end
