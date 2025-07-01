defmodule Counter do
  @name :counter

  # Client interface

  def start do
    pid = spawn(__MODULE__, :loop, [%{}])
    Process.register(pid, @name)
    pid
  end

  def bump_count(url_text) do
    send(@name, {:bump_count, url_text})
  end

  def get_count(url_text) do
    send(@name, {self(), :count, url_text})

    receive do
      {:response, count} ->
        count
    end
  end

  def get_counts do
    send(@name, {self(), :counts})

    receive do
      {:response, counts} ->
        counts
    end
  end

  # Server interface

  def loop(state) do
    receive do
      {:bump_count, url_text} ->
        new_state = Map.update(state, url_text, 1, &(&1 + 1))
        loop(new_state)
      {sender, :count, url_text} ->
        count = Map.get(state, url_text)
        send(sender, {:response, count})
        loop(state)
      {sender, :counts} ->
        send(sender, {:response, state})
        loop(state)
    end
  end
end
