defmodule Multiverses.FinchTest.Integration.PlugTest do
  use ExUnit.Case, async: true
  use Multiverses, with: Finch

  #################################################################
  # PLUG SECTION

  use Plug.Router

  use Multiverses.Finch.Plug

  plug :match
  plug :dispatch

  get "/" do
    TestModule.call()
    send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  ##################################################################
  ## TEST SECTION

  setup do
    # grab a free port and immediately close it
    {:ok, socket} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(socket)
    :erlang.port_close(socket)

    Plug.Cowboy.http __MODULE__, [], port: port
    {:ok, port: port}
  end

  test "one can start a server and dispatch to it", %{port: port} do
    test_pid = self()

    Mox.expect(TestModule, :call, fn ->
      send(test_pid, {:multiverse, Multiverses.self()})
    end)

    Finch.start_link(name: __MODULE__)

    {:ok, resp} = Finch.build(:get, "http://localhost:#{port}")
    |> Finch.request(__MODULE__)

    assert resp.status == 200
    assert_receive {:multiverse, multiverse}
    assert test_pid == multiverse
  end
end
