defmodule Servy do
  use Application

  # Writing this function overrides our generic behavior for the application.
  def start(_type, _args) do
    IO.puts("Starting the application....")

    # Returns a tuple `{:ok, sup_pid}`
    Servy.Supervisor.start_link()
  end
end
