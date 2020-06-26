import MultiversesTest.Replicant

defmoduler Multiverses.FinchTest.Integration.PlugTest do
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

  get "/task" do
    Task.async(fn -> TestModule.call() end)
    |> Task.await
    send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  ##################################################################
  ## TEST SECTION

  setup_all do
    # grab a free port and immediately close it
    {:ok, socket} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(socket)
    :erlang.port_close(socket)

    Plug.Cowboy.http __MODULE__, [], port: port
    Finch.start_link(name: __MODULE__)
    {:ok, port: port}
  end

  test "basic universe transfer is achieved", %{port: port} do
    test_pid = self()

    Mox.expect(TestModule, :call, fn ->
      send(test_pid, {:multiverse, Multiverses.self()})
    end)

    {:ok, resp} = Finch.build(:get, "http://localhost:#{port}")
    |> Finch.request(__MODULE__)

    assert resp.status == 200
    assert_receive {:multiverse, multiverse}
    assert test_pid == multiverse
  end

  test "being inside a task locally is not a problem", %{port: port} do
    test_pid = self()

    Mox.expect(TestModule, :call, fn ->
      send(test_pid, {:multiverse, Multiverses.self()})
    end)

    future = Task.async(fn ->
      {:ok, resp} = Finch.build(:get, "http://localhost:#{port}")
      |> Finch.request(__MODULE__)
      resp
    end)

    resp = Task.await(future)
    assert resp.status == 200
    assert_receive {:multiverse, multiverse}
    assert test_pid == multiverse
  end

  test "remote tasks are tied in correctly", %{port: port} do
    test_pid = self()

    Mox.expect(TestModule, :call, fn ->
      send(test_pid, {:multiverse, Multiverses.self()})
    end)

    {:ok, resp} = Finch.build(:get, "http://localhost:#{port}/task")
    |> Finch.request(__MODULE__)

    assert resp.status == 200
    assert_receive {:multiverse, multiverse}
    assert test_pid == multiverse
  end
end
