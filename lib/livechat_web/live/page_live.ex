defmodule LivechatWeb.PageLive do
  use LivechatWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("random-room", _params, socket) do
    {:noreply, push_redirect(socket, to: "/" <> MnemonicSlugs.generate_slug(4))}
  end

  @impl true
  def handle_event("join_room", %{"room" => %{"room_id" => room_id}}, socket) do
    {:noreply, push_redirect(socket, to: "/" <> room_id)}
  end
end
