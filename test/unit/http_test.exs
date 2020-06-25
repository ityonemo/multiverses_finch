defmodule Multiverses.FinchTest.Unit.HttpTest do
  use ExUnit.Case, async: true
  use Multiverses, with: Finch

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "one can start a server and dispatch to it", %{bypass: bypass} do
    test_pid = self()
    Bypass.expect(bypass, fn conn ->
      send(test_pid, {:headers, conn.req_headers})
      Plug.Conn.resp(conn, 200, "")
    end)

    Finch.start_link(name: __MODULE__)

    {:ok, resp} = Finch.build(:get, "http://localhost:#{bypass.port}")
    |> Finch.request(__MODULE__)

    assert resp.status == 200

    assert_receive {:headers, headers}
    assert universe_link = :proplists.get_value("universe", headers, nil)
    assert test_pid in (universe_link |> Base.decode64! |> :erlang.binary_to_term)
  end
end
