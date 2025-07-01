defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "smoke test" do
    assert 2 + 2 == 4
  end

  test "caches last three only" do
    # Start the server
    PledgeServer.start()

    # Create pledges
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    actual_last_three = PledgeServer.recent_pledges()

    Process.unregister(:pledge_server)

    assert [
             {"grace", 50},
             {"daisy", 40},
             {"curly", 30}
           ] == actual_last_three
  end

  test "totals last three only" do
    # Start the server
    PledgeServer.start()

    # Create pledges
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    actual_total = PledgeServer.total_pledged()

    Process.unregister(:pledge_server)

    assert 120 == actual_total
  end
end
