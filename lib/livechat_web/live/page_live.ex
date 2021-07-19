defmodule LivechatWeb.PageLive do
  use LivechatWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       query: "",
       random_id: MnemonicSlugs.generate_slug(4),
       room_id: "",
       results: %{}
     )}
  end

  @impl true
  def handle_event("join_room", %{"room" => %{"room_id" => ""}}, socket) do
    Logger.info("1")
    {:noreply, push_redirect(socket, to: "/" <> socket.assigns.random_id)}
  end

  @impl true
  def handle_event("join_room", %{"room" => %{"room_id" => room_id}}, socket) do
    Logger.info("2")
    {:noreply, push_redirect(socket, to: "/" <> room_id)}
  end

  @impl true
  def handle_event("form_update", %{"room" => %{"room_id" => room_id}}, socket) do
    {:noreply, assign(socket, room_id: room_id)}
  end
end
