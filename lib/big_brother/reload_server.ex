defmodule BigBrother.ReloadServer do
  @moduledoc """
    Supervisor responsible for starting core applications for code reloading.
  """

  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      BigBrother.CodeReloader.Server,
      BigBrother.FS.Watcher
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
