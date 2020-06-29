defmodule Multiverses.Finch.Plug do

  @moduledoc """
  provides a plug that will intercept Finch requests and establish
  port the plug handler process into the universe corresponding to
  the test.

  Downstream Tasks which are spawned from the plug handler will then
  be able to access allowances corresponding to the test (e.g. Mox
  allowances, or Ecto sandboxes)

  ## Usage

  ```
  defmoduler MyApp.Router do
    use Plug.Router

    # add the following two instructions to your router.
    # they will no-op in all environments where :use_multiverses is
    # not set to `true`

    use Multiverses, with: Finch
    use Multiverses.Finch.Plug

    # normal plug router code follows:

    plug :match
    plug :dispatch

    ...

  end
  ```
  """

  @doc false
  defmacro __using__(options) do
    otp_app = Keyword.get_lazy(options, :otp_app, fn ->
      Mix.Project.get
      |> apply(:project, [])
      |> Keyword.get(:app)
    end)

    if Application.get_env(otp_app, :use_multiverses) do
      quote do
        require Multiverses

        plug :port_universe

        def port_universe(conn, _opts) do
          case Plug.Conn.get_req_header(conn, "universe") do
            [] -> conn
            [universe] ->
              universe
              |> Base.url_decode64!
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
