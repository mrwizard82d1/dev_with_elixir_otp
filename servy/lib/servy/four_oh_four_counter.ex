defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter

  # Client interface

  def start do
    IO.puts("Starting the 404 counter...")

    pid = spawn(__MODULE__, :loop, [%{}])
    Process.register(pid, @name)
    pid
  end

  def bump_count(url_text) do
    send(@name, {self(), :bump_count, url_text})

    receive do {:response, count} -> count end
   end

  def get_count(url_text) do
    send(@name, {self(), :get_count, url_text})

    receive do {:response, count} -> count end
  end

  def get_counts do
    send(@name, {self(), :get_counts})

    receive do {:response, counts} -> counts end
  end

  # Server interface

  def loop(state) do
    receive do
      {sender, :bump_count, url_text} ->
        new_state = Map.update(state, url_text, 1, &(&1 + 1))
        send sender, {:response, Map.get(new_state, url_text)}
        loop(new_state)
      {sender, :get_count, url_text} ->
        count = Map.get(state, url_text, 0)
        send(sender, {:response, count})
        loop(state)
      {sender, :get_counts} ->
        send(sender, {:response, state})
        loop(state)
      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        loop(state)
    end
  end
end
