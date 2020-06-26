defmodule Multiverses.Finch do
  use Multiverses.MacroClone,
    module: Finch,
    except: [build: 2, build: 3, build: 4]

  defclone build(method, url, headers \\ [], body \\ nil) do
    link_id = Multiverses.link() |> :erlang.term_to_binary |> Base.encode64
    Finch.build(method,
      url,
      headers ++ [{"universe", link_id}],
      body)
  end
end
