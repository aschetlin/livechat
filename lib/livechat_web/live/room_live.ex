defmodule LivechatWeb.RoomLive do
  use LivechatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"room" => room_id}, _session, socket) do
    topic = "room: " <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      LivechatWeb.Endpoint.subscribe(topic)
      LivechatWeb.Presence.track(self(), topic, username, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       messages: [],
       user_list: [],
       typing: [],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{
      id: UUID.uuid4(),
      username: socket.assigns.username,
      content: message
    }

    LivechatWeb.Endpoint.broadcast(
      socket.assigns.topic,
      "new-message",
      message
    )

    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    LivechatWeb.Endpoint.broadcast(
      socket.assigns.topic,
      "new-typer",
      socket.assigns.username
    )

    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-typer", payload: typer}, socket) do
    existing = socket.assigns.typing
    typing = if typer in existing, do: existing, else: existing ++ [typer]
    {:noreply, assign(socket, typing: typing)}
  end

  @impl true
  def handle_info(%{event: "typing-update", payload: typers}, socket) do
    {:noreply, assign(socket, typing: typers)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    typers = List.delete(socket.assigns.typing, socket.assigns.username)

    LivechatWeb.Endpoint.broadcast(
      socket.assigns.topic,
      "typing-update",
      typers
    )

    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, id: UUID.uuid4(), content: "#{username} joined."}
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, id: UUID.uuid4(), content: "#{username} left."}
      end)

    user_list =
      LivechatWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()

    {:noreply,
     assign(socket,
       messages: join_messages ++ leave_messages,
       user_list: user_list
     )}
  end

  def display_message(%{type: :system, id: id, content: content}) do
    ~E"""
    <p id="<%= id %>"><em><%= content %></em></p>
    """
  end

  def display_message(%{id: id, content: content, username: username}) do
    ~E"""
    <p id="<%= id %>"><strong><%= username %></strong>: <%= content %></p>
    """
  end

  def display_typing(typers) do
    length = length(typers)

    cond do
      length == 0 ->
        ~E"""
        <em>&nbsp;</em>
        """

      length == 1 ->
        ~E"""
        <em><%= typers %> is typing...</em>
        """

      length > 1 && length < 4 ->
        ~E"""
        <em><%= Enum.join(typers, " and ") %> are typing...</em>
        """

      true ->
        ~E"""
        <em>several people are typing...</em>
        """
    end
  end
end
