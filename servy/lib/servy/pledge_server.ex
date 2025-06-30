defmodule Servy.PledgeServer do
  def init do
    spawn(__MODULE__, :listen_loop, [[]])
  end

  def listen_loop(state) do
    IO.puts("\nWaiting for a message...")

    receive do
      {:create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        new_state = [{name, amount} | state]
        IO.puts("#{name} pledged #{amount}!")
        IO.puts("New state is #{inspect(new_state)}")
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        IO.puts("Sent pledges to #{inspect(sender)}")
        listen_loop(state)
    end
  end

  def create_pledge(pid, name, amount) do
    send(pid, {:create_pledge, name, amount})
  end

  # def recent_pledges do
  #   # Return the most recent pledges from the cache
  #   [{"larry", 10}]
  # end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = spawn(PledgeServer, :listen_loop, [[]])

Servy.PledgeServer.create_pledge(pid, "larry", 10)
Servy.PledgeServer.create_pledge(pid, "moe", 20)
Servy.PledgeServer.create_pledge(pid, "curly", 30)
Servy.PledgeServer.create_pledge(pid, "daisy", 40)
Servy.PledgeServer.create_pledge(pid, "grace", 50)

send(pid, {self(), :recent_pledges})

receive do
  {:response, pledges} -> IO.inspect(pledges)
end
