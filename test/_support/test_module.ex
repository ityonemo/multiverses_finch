defmodule TestModuleApi do
  @callback call() :: nil
end

Mox.defmock(TestModule, for: TestModuleApi)
