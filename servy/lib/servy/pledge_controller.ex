defmodule Servy.PledgeController do
  alias Servy.View

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    Servy.PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conv | status_code: 200, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conv) do
    # Get the recent pledges from the cache
    pledges = Servy.PledgeServer.recent_pledges()

    View.render(conv, "recent_pledges.eex", pledges: pledges)
  end

  def new(conv) do
    View.render(conv, "new_pledge.eex")
  end
end
