defmodule Multiverses.Finch do

  @moduledoc """
  clones and instruments the Finch library with a substituted build
  method that allows universe assignments to escape the BEAM vm via http
  requests.

  This is useful to test APIs and HTTP requests in integration or end-to-end
  testing scenarios.

  The http request is instrumented with the `universe` header; this header
  contains the universe information serialized.  This can then be intercepted
  downstream using the `Multiverses.Finch.Plug` module.
  """

  use Multiverses.MacroClone,
    module: Finch,
    except: [build: 2, build: 3, build: 4]

  defclone build(method, url, headers \\ [], body \\ nil) do
    require Multiverses
    link_id = Multiverses.link() |> :erlang.term_to_binary |> Base.url_encode64
    Elixir.Finch.build(method,
      url,
      headers ++ [{"universe", link_id}],
      body)
  end
end
