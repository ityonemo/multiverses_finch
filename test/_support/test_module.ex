defmodule TestModuleApi do
  @moduledoc false
  @callback call() :: nil
end

Mox.defmock(TestModule, for: TestModuleApi)
