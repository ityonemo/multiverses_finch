defmodule Multiverses.Finch.Plug do
  defmacro __using__(options) do
    otp_app = Keyword.get_lazy(options, :otp_app, fn ->
      Mix.Project.get
      |> apply(:project, [])
      |> Keyword.get(:app)
    end)

    if Application.get_env(otp_app, :use_multiverses) do
      quote do
        plug :port_universe

        def port_universe(conn, _opts) do
          case Plug.Conn.get_req_header(conn, "universe") do
            [] -> conn
            [universe] ->
              universe |> IO.inspect(label: "17")
              |> Base.decode64!
              |> :erlang.binary_to_term
              |> Multiverses.port()

              conn
          end
        end
      end
    else
      quote do end
    end
  end
end
