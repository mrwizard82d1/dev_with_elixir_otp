defmodule Timer do
  def remind(message, after_seconds) do
    spawn(fn ->
      # convert to milliseconds
      :timer.sleep(after_seconds * 1000)
      IO.puts(message)
    end)
  end
end

Timer.remind("Stand Up", 5)
Timer.remind("Sit Down", 10)
Timer.remind("Fight, Fight, Fight", 15)
