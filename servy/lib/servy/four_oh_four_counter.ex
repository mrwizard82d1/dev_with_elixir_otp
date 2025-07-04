defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter

  use GenServer

  # Client interface

  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def bump_count(url_text) do
    GenServer.call(@name, {:bump_count, url_text})
  end

  def get_count(url_text) do
    GenServer.call(@name, {:get_count, url_text})
  end

  def get_counts do
    GenServer.call(@name, :get_counts)
  end

  def reset do
    GenServer.cast(@name, :reset)
  end

  # Server Callbacks

  # A default implementation to silence warning.
  def init(start_state) do
    {:ok, start_state}
  end

  def handle_call({:bump_count, url_text}, _from, state) do
    new_state = Map.update(state, url_text, 1, &(&1 + 1))
    {:reply, new_state, new_state}
  end

  def handle_call({:get_count, url_text}, _from, state) do
    count = Map.get(state, url_text, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:reset, state) do
    {:noreply, state}
  end
end
