defmodule FourOhFourCounterTest do
  use ExUnit.Case

  alias Servy.FourOhFourCounter

  test "reports counts of missing path requests" do
    pid = FourOhFourCounter.start()
    FourOhFourCounter.bump_count("/bigfoot")
    FourOhFourCounter.bump_count("/nessie")
    FourOhFourCounter.bump_count("/nessie")
    FourOhFourCounter.bump_count("/bigfoot")
    FourOhFourCounter.bump_count("/nessie")

    assert FourOhFourCounter.get_count("/nessie") == 3
    assert FourOhFourCounter.get_count("/bigfoot") == 2

    assert FourOhFourCounter.get_counts == %{"/bigfoot" => 2, "/nessie" => 3}

    Process.exit(pid, :kill)
  end
end
