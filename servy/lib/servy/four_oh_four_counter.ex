defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter

  alias Servy.GenericServer

  # Client interface

  def start do
    GenericServer.start(__MODULE__, %{}, @name)
  end

  def bump_count(url_text) do
    GenericServer.call(@name, {:bump_count, url_text})
   end

  def get_count(url_text) do
    GenericServer.call(@name, {:get_count, url_text})
  end

  def get_counts do
    GenericServer.call(@name, :get_counts)
  end

  def reset do
    GenericServer.cast(@name, :reset)
  end

  # Server Callbacks

  def handle_call({:bump_count, url_text}, state) do
    new_state = Map.update(state, url_text, 1, &(&1 + 1))
    {new_state, new_state}
  end

  def handle_call({:get_count, url_text}, state) do
    count = Map.get(state, url_text, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_cast(:reset, _state) do
    %{}
  end
end
