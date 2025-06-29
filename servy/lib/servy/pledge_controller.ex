defmodule Servy.PledgeController do
  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    Servy.PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conv | status_code: 200, resp_body: "#{name} pledget #{amount}!"}
  end

  def index(conv) do
    # Get the recent pledges from the cache
    pledges = Servy.PledgeServer.recent_pledges()

    %{conv | status_code: 200, resp_body: inspect(pledges)}
  end
end
